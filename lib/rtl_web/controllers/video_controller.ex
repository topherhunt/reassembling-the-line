defmodule RTLWeb.VideoController do
  use RTLWeb, :controller
  alias RTL.Videos

  plug :load_project
  plug :load_prompt when action in [:new, :create]

  def new(conn, _params) do
    changeset = Videos.Video.new_webcam_recording_changeset()
    uuid = RTL.Factory.random_uuid()

    render(conn, "new.html",
      changeset: changeset,
      filename_uuid: uuid,
      # Generate presigned upload urls for all supported filetypes.
      # (The JS only uses .jpg and .webm for now, but this approach gives us flexibility)
      presigned_upload_urls: %{
        jpg: presigned_upload_url("thumbnail", "#{uuid}.jpg"),
        webm: presigned_upload_url("recording", "#{uuid}.webm")
      }
    )

    # render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"video" => video_params}) do
    Videos.Video.insert_webcam_recording!(video_params)

    conn
    |> put_flash(:info, submission_confirmation_message())
    |> redirect(to: Routes.video_path(conn, :thank_you, conn.assigns.project))
  end

  def thank_you(conn, _params) do
    render(conn, "thank_you.html")
  end

  def show(conn, %{"id" => video_id}) do
    video = Videos.get_video!(video_id, project: conn.assigns.project)
    render(conn, "show.html", video: video)
  end

  #
  # Helpers
  #

  defp submission_confirmation_message do
    gettext("Thank you! We've received your recording and we're looking forward to learning from your experience.")
  end
end
