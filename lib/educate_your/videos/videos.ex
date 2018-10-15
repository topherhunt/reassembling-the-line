# This context contains relevant schemas & logic. No logic outside of this boundary
# may directly query against schemas in this context, or call context-private methods.
defmodule EducateYour.Videos do
  import Ecto.Query
  import Ecto.Changeset
  import EducateYour.Helpers
  alias EducateYour.Repo
  alias EducateYour.Videos.{Video, Coding, Tag, Tagging, Attachment}

  #
  # Global
  #

  def delete_all_content do
    Repo.delete_all(Video)
    Repo.delete_all(Coding)
    Repo.delete_all(Tagging)
    Repo.delete_all(Tag)
  end

  #
  # Videos
  #

  def get_video!(id), do: Video |> Repo.get!(id)
  def next_video_to_code, do: Video.uncoded |> Video.sort_by_newest |> Repo.first
  def all_videos_with_preloads, do:
    Video |> Video.sort_by_newest |> preload([coding: [:updated_by_user, :tags]]) |> Repo.all
  def videos_tagged_with(tags), do: Video.tagged_with(tags) |> Video.preload_tags |> Repo.all
  def count_all_videos, do: Video |> Repo.count
  def count_videos_where(constraints), do: Video |> where(^constraints) |> Repo.count
  def insert_video!(%{} = params), do: video_changeset(%Video{}, params) |> Repo.insert!
  def video_changeset(video \\ %Video{}, changes), do: Video.changeset(video, changes)

  #
  # File attachments
  #

  def url_to_hash(url), do: :crypto.hash(:md5, url) |> Base.encode16
  def upload_recording(file_path), do: Attachment.store({file_path, "recording"})
  def upload_thumbnail(file_path), do: Attachment.store({file_path, "thumbnail"})
  def recording_url(v), do: Attachment.url({v.recording_filename, "recording"})
  def thumbnail_url(v), do: Attachment.url({v.thumbnail_filename, "thumbnail"})

  #
  # Codings
  #

  def get_coding!(coding_id), do: Repo.get!(Coding, coding_id)
  def get_coding_by!(params), do: Repo.get_by!(Coding, params)
  def get_coding_preloads(coding), do: Repo.preload(coding, [:video, [taggings: :tag]])
  def coding_changeset(coding \\ %Coding{}, changes), do: Coding.changeset(coding, changes)

  def insert_coding(%{video_id: video_id, coder_id: coder_id, tags: tags_params}) do
    # TODO: Validate format of tag_params list
    changeset = coding_changeset(%Coding{}, %{
      video_id: video_id,
      updated_by_user_id: coder_id})
    case validate_tags(tags_params) do
      {:ok} ->
        coding = Repo.insert!(changeset)
        apply_tags_to_coding(coding, tags_params)
        {:ok, coding}
      {:error, invalid_tags} -> {:error, changeset, invalid_tags}
    end
  end

  def update_coding(%{coding: coding, tags: tags_params, coder_id: coder_id}) do
    # TODO: Validate format of tag_params list
    changeset = coding_changeset(coding, %{updated_by_user_id: coder_id})
    case validate_tags(tags_params) do
      {:ok} ->
        coding = Repo.update!(changeset)
        apply_tags_to_coding(coding, tags_params)
        {:ok, coding}
      {:error, invalid_tags} -> {:error, changeset, invalid_tags}
    end
  end

  #
  # Taggings
  #

  def all_tags, do: Tag |> order_by([t], t.text) |> Repo.all
  def insert_tagging!(%{} = params), do: tagging_changeset(%Tagging{}, params) |> Repo.insert!
  def tagging_changeset(tagging, changes), do: Tagging.changeset(tagging, changes)

  def summarize_taggings(taggings) do
    # assumes %{taggings: :tag} is already preloaded
    Enum.map(taggings, fn(tagging)->
      %{
        text: tagging.tag.text,
        starts_at: integer_to_time(tagging.starts_at),
        ends_at: integer_to_time(tagging.ends_at)
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
      |> order_by([t, ti], [desc: count(ti.id), asc: t.text])
      |> Repo.all
      |> Enum.map(fn({text, ct}) -> %{text: text, count: ct} end)
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
    invalid_tags = tags_params
      |> Enum.reject(fn(params)-> is_blank?(params["text"]) end)
      |> Enum.map(fn(tag_params) -> tag_changeset(%Tag{}, tag_params) end)
      |> Enum.reject(fn(changeset) -> changeset.valid? end)
      |> Enum.map(fn(changeset) -> Ecto.Changeset.get_field(changeset, :text) end)
    case invalid_tags do
      [] -> {:ok}
      _ -> {:error, invalid_tags}
    end
  end

  defp apply_tags_to_coding(%Coding{} = coding, tags_list) do
    # TODO: Validate the format of tags_list?
    # eg. Helpers.assert_each_matches(tags_list, %{"text" => _, "starts_at" => _, "ends_at" => _})
    coding |> Ecto.assoc(:taggings) |> Repo.delete_all # Clear out existing tags
    tags_list
      |> Enum.reject(fn(params)-> is_blank?(params["text"]) end)
      |> Enum.each(fn(params) ->
        tag = find_or_create_tag(params)
        insert_tagging!(%{
          coding_id: coding.id,
          tag_id: tag.id,
          starts_at: time_to_integer(params["starts_at"]),
          ends_at: time_to_integer(params["ends_at"])
        })
      end)
  end
end
