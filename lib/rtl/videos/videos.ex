# This context contains relevant schemas & logic. No logic outside of this boundary
# may directly query against schemas in this context, or call context-private methods.
defmodule RTL.Videos do
  import Ecto.Query
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

  def get_video(id, filt \\ []), do: get_video_by([{:id, id} | filt])
  def get_video!(id, filt \\ []), do: get_video_by!([{:id, id} | filt])
  def get_video_by(filt), do: Video |> Video.apply_filters(filt) |> Repo.first()
  def get_video_by!(filt), do: Video |> Video.apply_filters(filt) |> Repo.first!()
  def list_videos(filt \\ []), do: Video |> Video.apply_filters(filt) |> Repo.all()
  def count_videos(filt \\ []), do: Video |> Video.apply_filters(filt) |> Repo.count()

  def new_video_changeset(params \\ %{}), do: Video.generic_changeset(%Video{}, params)

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

  def presigned_url(path) do
    # See https://stackoverflow.com/a/42211543/1729692
    bucket = System.get_env("S3_BUCKET")
    config = ExAws.Config.new(:s3)
    params = [{"x-amz-acl", "public-read"}, {"contentType", "binary/octet-stream"}]
    {:ok, url} = ExAws.S3.presigned_url(config, :put, bucket, path, query_params: params)
    url
  end

  #
  # Codings
  #

  def get_coding(id, f \\ []), do: get_coding_by([{:id, id} | f])
  def get_coding!(id, f \\ []), do: get_coding_by!([{:id, id} | f])
  def get_coding_by(f \\ []), do: Coding |> Coding.apply_filters(f) |> Repo.first()
  def get_coding_by!(f \\ []), do: Coding |> Coding.apply_filters(f) |> Repo.first!()
  def list_codings(f \\ []), do: Coding |> Coding.apply_filters(f) |> Repo.all()
  def count_codings(f \\ []), do: Coding |> Coding.apply_filters(f) |> Repo.count()

  def insert_coding!(attrs) do
    %Coding{} |> Coding.changeset(attrs) |> Repo.insert!()
  end

  def update_coding!(coding, attrs) do
    coding |> Coding.changeset(attrs) |> Repo.update!()
  end

  def coding_changeset(attrs \\ %{}), do: Coding.changeset(%Coding{}, attrs)

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

  def get_tag_by(params), do: Repo.get_by(Tag, params)

  def tag_changeset(tag, changes), do: Tag.changeset(tag, changes)

  def insert_tag(params) do
    %Tag{} |> Tag.changeset(params) |> Repo.insert()
  end

  def insert_tag!(params) do
    insert_tag(params) |> Repo.ensure_success()
  end

  # TODO: Is there another way to do this that's more friendly to my filters system?
  def all_tags_with_counts do
    Tag
    |> join(:inner, [t], ti in Tagging, t.id == ti.tag_id)
    |> group_by([t, ti], [t.text])
    |> select([t, ti], {t.text, count(ti.id)})
    |> order_by([t, ti], desc: count(ti.id), asc: t.text)
    |> Repo.all()
    |> Enum.map(fn {text, ct} -> %{text: text, count: ct} end)
  end

end
