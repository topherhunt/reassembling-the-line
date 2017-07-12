defmodule EducateYour.Admin.CodingController do
  use EducateYour.Web, :controller
  alias EducateYour.{Video, Coding, Tag, Tagging}
  import Ecto.Changeset

require IEx

  def new(conn, %{"video_id" => video_id}) do
    video = Repo.get!(Video, video_id)
    changeset = Coding.create_changeset(%Coding{video_id: video.id}, %{})
    render conn, "new.html",
      video: video,
      changeset: changeset,
      all_tags: all_tags()
  end

  def create(conn, %{"coding" => %{"video_id" => video_id, "tags" => tags_params}} = params) do
    changeset = Coding.create_changeset(
      %Coding{},
      %{video_id: video_id, updated_by_user_id: conn.assigns.current_user.id}
    )
    coding = Repo.insert!(changeset) # We assume the data will be valid.
    Coding.associate_tags(coding, Map.values(tags_params))
    redirect_to_code_next(conn)
  end

  def edit(conn, %{"id" => coding_id}) do
    coding = Repo.get!(Coding, coding_id) |> Repo.preload(:video)
    changeset = Coding.update_changeset(coding, %{})
    render conn, "edit.html",
      video: coding.video,
      changeset: changeset,
      all_tags: all_tags()
  end

  def update(conn, %{"id" => coding_id, "coding" => %{"tags" => tags_params}}) do
    coding = Repo.get!(Coding, coding_id)
    changeset = Coding.update_changeset(
      coding,
      %{updated_by_user_id: conn.assigns.current_user.id}
    )
    Repo.update!(changeset) # no concern about invalid data here
    remove_tag_associations(coding)
    Coding.associate_tags(coding, Map.values(tags_params))
    conn
      |> put_flash(:info, "Your updates have been saved.")
      |> redirect(to: admin_video_path(conn, :index))
  end

  # Helpers

  defp all_tags do
    Tag |> order_by([t], [t.context, t.text]) |> Repo.all
  end

  defp remove_tag_associations(coding) do
    coding
      |> assoc(:taggings)
      |> Repo.delete_all
  end

  defp redirect_to_code_next(conn) do
    if video = next_video_to_code() do
      conn
        |> put_flash(:info, "Your updates have been saved! Here's another video to code.")
        |> redirect(to: admin_coding_path(conn, :new, video_id: video.id))
    else
      conn
        |> put_flash(:info, "Your updates have been saved! There are no more videos to code.")
        |> redirect(to: admin_video_path(conn, :index))
    end
  end

  defp next_video_to_code do
    Video
      |> where([v], fragment("NOT EXISTS (SELECT * FROM codings WHERE video_id = ?)", v.id))
      # TODO: Sort by date or something?
      |> Repo.first
  end
end
