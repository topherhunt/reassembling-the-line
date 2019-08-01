defmodule RTLWeb.Manage.VideoController do
  use RTLWeb, :controller
  import RTL.Videos, only: [presigned_url: 1]
  alias RTL.{Factory, Projects, Videos}
  alias RTL.Videos.{Video, Coding}

  plug :load_project
  plug :ensure_can_manage_project

  def index(conn, _params) do
    # Instead of rendering a normal view template, we render a Liveview here.
    # The Liveview process is responsible for fetching all needed data.
    live_render(conn, RTLWeb.Manage.VideosListLiveview, session: %{project: conn.assigns.project})
  end

  # Admin video upload page
  def new(conn, _params) do
    prompts = Projects.get_prompts(project: conn.assigns.project)
    changeset = Videos.new_video_changeset()
    uuid = Factory.random_uuid()

    render(conn, "new.html",
      prompts: prompts,
      changeset: changeset,
      filename_uuid: uuid,
      # Generate presigned upload urls for all supported filetypes.
      # (Can't request the upload url later via ajax; that would enable S3 upload attacks)
      presigned_upload_urls: %{
        jpg: presigned_url("uploads/thumbnail/#{uuid}.jpg"),
        mp4: presigned_url("uploads/recording/#{uuid}.mp4"),
        webm: presigned_url("uploads/recording/#{uuid}.webm")
      }
    )
  end

  # Admin video upload submit
  def create(conn, %{"video" => video_params}) do
    Videos.insert_video!(video_params)

    conn
    |> put_flash(:info, "Video imported.")
    |> redirect(to: Routes.manage_project_path(conn, :show, conn.assigns.project))
  end

  # The coding page
  # Most of the coding page data is loaded by Apollo, so we don't have much to do here.
  # (In the future we might support multiple codings of the same video, but for now
  #  there's just one associated coding record.)
  def code(conn, _params) do
    video = load_video(conn)
    coder = conn.assigns.current_user
    coding = find_or_create_coding(video, coder)
    changeset = Coding.changeset(coding)
    render conn, "code.html", video: video, coding: coding, changeset: changeset
  end

  # Called when the user clicks the "Mark completed" button to finalize coding.
  # This coding will then be treated as complete, though it can still be edited.
  def mark_coded(conn, params) do
    project = conn.assigns.project
    video = load_video(conn)
    coding = Coding.first(video: video)
    params = %{coder_id: conn.assigns.current_user.id, completed_at: Timex.now()}
    Coding.update!(coding, params)
    redirect(conn, to: Routes.manage_video_path(conn, :index, project))
  end

  #
  # Helpers
  #

  defp load_video(conn) do
    Video.get!(conn.params["video_id"], project: conn.assigns.project, preload: :prompt)
  end

  defp find_or_create_coding(video, coder) do
    Coding.first(video: video, preload: :coder) ||
    Coding.insert!(%{video_id: video.id, coder_id: coder.id})
  end
end
