# This context contains relevant schemas & logic. No logic outside of this boundary
# may directly query against schemas in this context, or call context-private methods.
defmodule RTL.Videos do
  import Ecto.Query
  import Ecto.Changeset
  alias RTL.Helpers, as: H
  alias RTL.TimeParser
  alias RTL.Repo
  alias RTL.Videos.{Video, Coding, Tag, Tagging, Attachment}

  #
  # Pubsub notifications
  #

  # Makes the caller process listen for any notifications on this channel.
  # On any events, the caller module's handle_info/2 will be called with the payload.
  def subscribe_to(:all) do
    Phoenix.PubSub.subscribe(RTL.PubSub, "RTL.Videos")
  end

  # Expects an Ecto result tuple {:ok, _} or {:error, _}
  def notify_subscribers_if_succeeded({code, _} = piped_result, event) do
    if code == :ok, do: notify_subscribers(event)
    piped_result
  end

  def notify_subscribers(piped_result \\ nil, event) do
    # For now, I'll just broadcast to one channel global to the context.
    # In the future I might want specific channels for each schema or even each id.
    # The recipient doesn't see what channel a message came from,
    # so the payload must redundantly declare the source module.
    Phoenix.PubSub.broadcast(RTL.PubSub, "RTL.Videos", {RTL.Videos, event})
    piped_result
  end

  #
  # Global
  #

  def delete_all_content do
    Repo.delete_all(Video)
    Repo.delete_all(Coding)
    Repo.delete_all(Tagging)
    Repo.delete_all(Tag)

    notify_subscribers("videos.deleted_all")
  end

  #
  # Videos
  #

  def get_video(id, filt \\ []), do: get_video_by(Keyword.merge([id: id], filt))

  def get_video!(id, filt \\ []), do: get_video_by!(Keyword.merge([id: id], filt))

  def get_video_by(filt), do: Video |> Video.filter(filt) |> Repo.first()

  def get_video_by!(filt), do: Video |> Video.filter(filt) |> Repo.first!()

  def get_videos(filt \\ []), do: Video |> Video.filter(filt) |> Repo.all()

  def count_videos(filt \\ []), do: Video |> Video.filter(filt) |> Repo.count()

  def new_video_changeset(params \\ %{}), do: Video.changeset(%Video{}, params)

  def insert_video(params) do
    new_video_changeset(params)
    |> Repo.insert()
    |> notify_subscribers_if_succeeded("videos.inserted")
  end

  def insert_video!(params) do
    new_video_changeset(params)
    |> Repo.insert!()
    |> notify_subscribers("videos.inserted")
  end

  def delete_video!(video) do
    Repo.delete!(video)
    |> notify_subscribers("videos.deleted.#{video.id}")
  end

  #
  # File attachments
  #

  def url_to_hash(url), do: :crypto.hash(:md5, url) |> Base.encode16()

  def upload_recording(file_path), do: Attachment.store({file_path, "recording"})

  def upload_thumbnail(file_path), do: Attachment.store({file_path, "thumbnail"})

  def recording_url(v), do: Attachment.url({v.recording_filename, "recording"})

  def thumbnail_url(v), do: Attachment.url({v.thumbnail_filename, "thumbnail"})

  #
  # Codings
  #

  def get_coding(coding_id), do: Repo.get(Coding, coding_id)

  def get_coding!(coding_id), do: Repo.get!(Coding, coding_id)

  def get_coding_by!(params), do: Repo.get_by!(Coding, params)

  def get_coding_preloads(coding), do: Repo.preload(coding, [:video, [taggings: :tag]])

  def coding_changeset(changes), do: Coding.changeset(%Coding{}, changes)

  def coding_changeset(struct, changes), do: Coding.changeset(struct, changes)

  def insert_coding(%{video_id: video_id, coder_id: coder_id, tags: tags_params}) do
    # TODO: Validate format of tag_params list
    changeset = coding_changeset(%{video_id: video_id, updated_by_user_id: coder_id})

    case validate_tags(tags_params) do
      {:ok} ->
        coding = Repo.insert!(changeset)
        apply_tags_to_coding(coding, tags_params)
        notify_subscribers("coding.inserted")
        {:ok, coding}

      {:error, invalid_tags} ->
        {:error, changeset, invalid_tags}
    end
  end

  def update_coding(%{coding: coding, tags: tags_params, coder_id: coder_id}) do
    # TODO: Validate format of tag_params list

    changeset = coding_changeset(coding, %{updated_by_user_id: coder_id})

    case validate_tags(tags_params) do
      {:ok} ->
        coding = Repo.update!(changeset)
        apply_tags_to_coding(coding, tags_params)
        notify_subscribers("coding.updated.#{coding.id}")
        {:ok, coding}

      {:error, invalid_tags} ->
        {:error, changeset, invalid_tags}
    end
  end

  #
  # Taggings
  #

  def all_tags, do: Tag |> order_by([t], asc: t.text) |> Repo.all()

  def most_recent_tags(n) do
    from(t in Tag,
      inner_join: ti in assoc(t, :taggings),
      group_by: t.id,
      order_by: t.text,
      limit: ^n
    )
    |> Repo.all()

    # I could also sort by how recently they were applied:
    # |> order_by([t, ti], desc: fragment("MAX(?)", ti.inserted_at))
  end

  def insert_tagging!(%{} = params) do
    tagging_changeset(%Tagging{}, params) |> Repo.insert!()
  end

  def tagging_changeset(tagging, changes), do: Tagging.changeset(tagging, changes)

  def summarize_taggings(taggings) do
    # assumes %{taggings: :tag} is already preloaded
    Enum.map(taggings, fn tagging ->
      %{
        text: tagging.tag.text,
        starts_at: TimeParser.float_to_string(tagging.starts_at),
        ends_at: TimeParser.float_to_string(tagging.ends_at)
      }
    end)
  end

  #
  # Tags
  #

  def tag_changeset(tag, changes), do: Tag.changeset(tag, changes)

  def all_tags_with_counts do
    Tag
    |> join(:inner, [t], ti in Tagging, t.id == ti.tag_id)
    |> group_by([t, ti], [t.text])
    |> select([t, ti], {t.text, count(ti.id)})
    |> order_by([t, ti], desc: count(ti.id), asc: t.text)
    |> Repo.all()
    |> Enum.map(fn {text, ct} -> %{text: text, count: ct} end)
  end

  def find_or_create_tag(params) do
    chg = tag_changeset(%Tag{}, params)
    sanitized_text = get_change(chg, :text)
    Repo.get_by(Tag, text: sanitized_text) || Repo.insert!(chg)
  end

  #
  # Internal helpers
  # TODO: Maybe these should be moved to a helper submodule?
  #

  defp validate_tags(tags_params) do
    # TODO: Validate the tags_params format
    invalid_tags =
      tags_params
      |> Enum.reject(fn params -> H.is_blank?(params["text"]) end)
      |> Enum.map(fn tag_params -> tag_changeset(%Tag{}, tag_params) end)
      |> Enum.reject(fn changeset -> changeset.valid? end)
      |> Enum.map(fn changeset -> Ecto.Changeset.get_field(changeset, :text) end)

    case invalid_tags do
      [] -> {:ok}
      _ -> {:error, invalid_tags}
    end
  end

  defp apply_tags_to_coding(%Coding{} = coding, tags_list) do
    # TODO: Validate the format of tags_list?
    # eg. H.assert_each_matches(tags_list, %{"text" => _, "starts_at" => _, "ends_at" => _})
    # Clear out existing tags
    coding |> Ecto.assoc(:taggings) |> Repo.delete_all()

    tags_list
    |> Enum.reject(&H.is_blank?(&1["text"]))
    |> Enum.each(fn params ->
      tag = find_or_create_tag(params)

      insert_tagging!(%{
        coding_id: coding.id,
        tag_id: tag.id,
        starts_at: TimeParser.string_to_float(params["starts_at"]),
        ends_at: TimeParser.string_to_float(params["ends_at"])
      })
    end)
  end
end
