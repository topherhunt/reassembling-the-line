defmodule RTLWeb.Manage.VideoController do
  use RTLWeb, :controller
  import RTL.Videos, only: [presigned_url: 1]
  alias RTL.{Factory, Projects, Videos}

  plug :load_project
  plug :ensure_can_manage_project

  def index(conn, _params) do
    # Instead of rendering a normal view template, we render a Liveview here.
    # The Liveview process is responsible for fetching all needed data.
    live_render(conn, RTLWeb.Manage.VideosListLiveview, session: %{project: conn.assigns.project})
  end

  # Admin video upload page (maybe the admin upload deserves its own controller?)
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

  def create(conn, %{"video" => video_params}) do
    Videos.insert_video!(video_params)

    conn
    |> put_flash(:info, "Video imported.")
    |> redirect(to: Routes.manage_project_path(conn, :show, conn.assigns.project))
  end
end
