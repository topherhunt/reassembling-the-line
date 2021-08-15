defmodule RTLWeb.Admin.VideoController do
  use RTLWeb, :controller
  alias RTL.{Repo, Videos}
  alias RTL.Videos.Video
  import Ecto.Query

  plug :load_project
  plug :ensure_can_manage_project

  def index(conn, _params) do
    project = conn.assigns.project
    videos =
      Video.filter(project: project, order: :last_coded)
      |> preload(coding: [:coder, :tags])
      |> Repo.all()
    next_uncoded_video =
      Video.filter(project: project, coded: false, order: :last_coded)
      |> Repo.first()

    render conn, "index.html", videos: videos, next_uncoded_video: next_uncoded_video
  end

  def delete(conn, %{"id" => id}) do
    project = conn.assigns.project
    video = Video.filter(project: project, id: id) |> Repo.one!()
    Videos.delete_video!(video)

    conn
    |> put_flash(:info, "Video #{id} deleted.")
    |> redirect(to: Routes.admin_video_path(conn, :index, project))
  end

  # The coding page
  # Most of the coding page data is loaded by Apollo, so we don't have much to do here.
  # (In the future we might support multiple codings of the same video, but for now
  #  there's just one associated coding record.)
  def code(conn, _params) do
    video = load_video(conn)
    coder = conn.assigns.current_user
    coding = find_or_create_coding(video, coder)
    changeset = Videos.coding_changeset()
    render conn, "code.html", video: video, coding: coding, changeset: changeset
  end

  # Called when the user clicks the "Mark completed" button to finalize coding.
  # This coding will then be treated as complete, though it can still be edited.
  def mark_coded(conn, _params) do
    project = conn.assigns.project
    video = load_video(conn)
    coding = Videos.get_coding_by!(video: video)
    coder = conn.assigns.current_user
    Videos.update_coding!(coding, %{coder_id: coder.id, completed_at: Timex.now()})

    conn
    |> put_flash(:info, gettext("Video marked as complete!"))
    |> redirect(to: Routes.admin_video_path(conn, :index, project))
  end

  #
  # Helpers
  #

  defp load_video(conn) do
    id = conn.params["video_id"]
    project = conn.assigns.project
    Videos.get_video!(id, project: project, preload: :prompt)
  end

  defp find_or_create_coding(video, coder) do
    Videos.get_coding_by(video: video, preload: :coder) ||
    Videos.insert_coding!(%{video_id: video.id, coder_id: coder.id})
  end
end
