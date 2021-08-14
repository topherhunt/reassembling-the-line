defmodule RTLWeb.VideoController do
  use RTLWeb, :controller
  alias RTL.Videos
  alias RTL.Videos.{Attachment, Video}

  plug :load_project
  plug :load_prompt when action in [:new, :create]

  def new(conn, _params) do
    changeset = Video.changeset(%Video{}, %{}, :webcam_recording)
    timestamp = H.now() |> H.print_datetime("%Y%m%d-%H%M%S")
    filename = "#{timestamp}-#{Nanoid.generate(4)}"

    render(conn, "new.html",
      changeset: changeset,
      filename_base: filename,
      # Generate presigned upload urls for all supported filetypes.
      # (The JS only uses .jpg and .webm for now, but this approach gives us flexibility)
      presigned_upload_urls: %{
        jpg: Attachment.presigned_upload_url("#{filename}.jpg"),
        webm: Attachment.presigned_upload_url("#{filename}.webm")
      }
    )
  end

  # The form submits here once the video has finished uploading.
  def create(conn, %{"video" => video_params}) do
    video = Videos.insert_video!(video_params, :webcam_recording)

    # Start a AWS MediaConverter job to convert the video to standard .mp4 format.
    Videos.MediaConvertWrapper.create_job(Attachment.path(video.recording_filename))

    # Users must be given the (yet-to-be-converted) .mp4 recording, not the .webm.
    mp4_filename = video.recording_filename |> String.replace(".webm", ".mp4")
    Videos.update_video!(video, %{recording_filename: mp4_filename})

    conn
    |> put_flash(:info, gettext("Thank you! We've received your recording and we're looking forward to learning from your experience."))
    |> redirect(to: Routes.video_path(conn, :thank_you, conn.assigns.project))
  end

  def thank_you(conn, _params) do
    render(conn, "thank_you.html")
  end

  def show(conn, %{"id" => video_id}) do
    video = Videos.get_video!(video_id, project: conn.assigns.project)
    render(conn, "show.html", video: video)
  end
end
