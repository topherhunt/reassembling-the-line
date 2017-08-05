defmodule EducateYour.Admin.CodingController do
  use EducateYour.Web, :controller
  alias EducateYour.{H, Video, Coding, Tag}

  def new(conn, %{"video_id" => video_id}) do
    video = Repo.get!(Video, video_id)
    changeset = Coding.create_changeset(%Coding{video_id: video.id}, %{})
    render conn, "new.html",
      video: video,
      changeset: changeset,
      # TODO: Should load tags separately per context, that way the filtering
      # doesn't need to be done client-side
      all_tags: all_tags(),
      present_tags: []
  end

  def create(conn, %{"coding" => coding_params}) do
    video_id = coding_params["video_id"]
    tags_params = Map.values(coding_params["tags"] || %{})
    changeset = Coding.create_changeset(%Coding{}, %{video_id: video_id, updated_by_user_id: conn.assigns.current_user.id})
    case get_invalid_tags(tags_params) do
      [] ->
        coding = Repo.insert!(changeset)
        Coding.associate_tags(coding, tags_params)
        redirect_to_code_next(conn)
      invalid_tags ->
        video = Repo.get!(Video, video_id)
        render_error(conn, "new", changeset, video, tags_params, invalid_tags)
    end
  end

  def edit(conn, %{"id" => coding_id}) do
    coding = Repo.get!(Coding, coding_id) |> Repo.preload([:video, [taggings: :tag]])
    changeset = Coding.update_changeset(coding, %{})
    render conn, "edit.html",
      video: coding.video,
      changeset: changeset,
      all_tags: all_tags(),
      present_tags: Coding.compact_tag_info(coding)
  end

  def update(conn, %{"id" => coding_id, "coding" => coding_params}) do
    tags_params = Map.values(coding_params["tags"] || %{})
    coding = Repo.get!(Coding, coding_id)
    changeset = Coding.update_changeset(coding, %{updated_by_user_id: conn.assigns.current_user.id})
    case get_invalid_tags(tags_params) do
      [] ->
        Repo.update!(changeset)
        remove_tag_associations(coding)
        Coding.associate_tags(coding, tags_params)
        conn
          |> put_flash(:info, "Updates are saved.")
          |> redirect(to: admin_video_path(conn, :index))
      invalid_tags ->
        video = Repo.get!(Video, coding.video_id)
        render_error(conn, "edit", changeset, video, tags_params, invalid_tags)
    end
  end

  # Helpers

  defp all_tags do
    Tag |> order_by([t], [t.context, t.text]) |> Repo.all
  end

  def get_invalid_tags(tags_params) do
    tags_params
      |> Enum.reject(fn(params)-> H.is_blank?(params["text"]) end)
      |> Enum.map(fn(tag_params) -> Tag.changeset(%Tag{}, tag_params) end)
      |> Enum.reject(fn(changeset) -> changeset.valid? end)
      |> Enum.map(fn(changeset) -> Ecto.Changeset.get_field(changeset, :text) end)
  end

  defp remove_tag_associations(coding) do
    coding
      |> assoc(:taggings)
      |> Repo.delete_all
  end

  defp redirect_to_code_next(conn) do
    if video = next_video_to_code() do
      conn
        |> put_flash(:info, "Updates are saved! Here's another video to code.")
        |> redirect(to: admin_coding_path(conn, :new, video_id: video.id))
    else
      conn
        |> put_flash(:info, "Updates are saved! There are no more videos to code.")
        |> redirect(to: admin_video_path(conn, :index))
    end
  end

  defp next_video_to_code do
    Video
      |> where([v],
        fragment("NOT EXISTS (SELECT * FROM codings WHERE video_id = ?)", v.id))
      # TODO: Sort by date or something?
      |> Repo.first
  end

  defp render_error(conn, view, changeset, video, tags_params, invalid_tags) do
    conn
      |> put_flash(:error, "Unable to save your changes because tags must only contain letters, numbers, and spaces. These tags are invalid: [#{Enum.join(invalid_tags, ", ")}]")
      |> render("#{view}.html",
        video: video,
        changeset: changeset,
        all_tags: all_tags(),
        present_tags: compact_tag_info_from_params(tags_params))
  end

  def compact_tag_info_from_params(tags_params) do
    tags_params
      |> Enum.map(fn(tag) ->
        %{
          context: tag["context"],
          text: tag["text"],
          starts_at: tag["starts_at"],
          ends_at: tag["ends_at"]
        }
      end)
  end
end
