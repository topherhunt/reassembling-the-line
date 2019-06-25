defmodule RTLWeb.Share.FromWebcamController do
  use RTLWeb, :controller
  import RTL.Videos, only: [presigned_url: 1]
  alias RTL.{Factory, Videos}

  plug :load_project
  plug :load_prompt

  # For now, we don't require a logged-in user nor any sort of voucher code.
  # Anyone can record and upload a recording as many times as they want.
  def new(conn, _params) do
    changeset = Videos.Video.new_webcam_recording_changeset()
    uuid = Factory.random_uuid()

    render(conn, "new.html",
      changeset: changeset,
      filename_uuid: uuid,
      # Generate presigned upload urls for all supported filetypes.
      # (The JS only uses .jpg and .webm for now, but this approach gives us flexibility)
      presigned_upload_urls: %{
        jpg: presigned_url("uploads/thumbnail/#{uuid}.jpg"),
        webm: presigned_url("uploads/recording/#{uuid}.webm")
      }
    )
  end

  def create(conn, %{"video" => video_params}) do
    project = conn.assigns.project
    prompt = conn.assigns.prompt

    Videos.Video.insert_webcam_recording!(video_params)

    conn
    |> put_flash(:info, submission_confirmation_message())
    |> redirect(to: Routes.share_from_webcam_path(conn, :thank_you, project, prompt))
  end

  def thank_you(conn, _params) do
    render(conn, "thank_you.html")
  end

  #
  # Helpers
  #

  defp submission_confirmation_message do
    "Thank you! We've received your recording and we're looking forward to learning from your experience."
  end
end
