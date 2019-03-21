defmodule RTLWeb.Collect.WebcamRecordingController do
  use RTLWeb, :controller
  alias RTL.Videos
  import RTL.Helpers, only: [is_present?: 1]

  # For now, we don't require a logged-in user nor any sort of voucher code.
  # Anyone can record and upload an interview as many times as they want.
  def new(conn, _params) do
    changeset = Videos.new_video_changeset(%{})
    uuid = RTL.Helpers.random_hex()
    thumbnail_filename = "#{uuid}.jpg"
    recording_filename = "#{uuid}.webm"

    render(conn, "new.html",
      changeset: changeset,
      thumbnail_filename: thumbnail_filename,
      recording_filename: recording_filename,
      thumbnail_presigned_s3_url: presigned_url("uploads/thumbnail/#{thumbnail_filename}"),
      recording_presigned_s3_url: presigned_url("uploads/recording/#{recording_filename}")
    )
  end

  def create(conn, %{"video" => video_params}) do
    # For now, assume that there's no risk of validation errors
    Videos.insert_video!(populate_title(video_params))

    conn
    |> put_flash(:info, "Thank you! We've received your interview and we're looking forward to learning from your experience.")
    |> redirect(to: home_path(conn, :index))
  end

  #
  # Helpers
  #

  defp presigned_url(path) do
    # See https://stackoverflow.com/a/42211543/1729692
    bucket = System.get_env("S3_BUCKET")
    {:ok, url} = ExAws.S3.presigned_url(ExAws.Config.new(:s3), :put, bucket, path,
      query_params: [{"x-amz-acl", "public-read"}, {"contentType", "binary/octet-stream"}]
    )
    url
  end

  defp populate_title(params) do
    title = if is_present?(params["source_name"]) do
      "Interview with #{params["source_name"]}"
    else
      "Anonymous interview"
    end

    Map.merge(params, %{"title" => title})
  end
end
