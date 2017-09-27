defmodule EducateYour.VideoController do
  use EducateYour.Web, :controller
  alias EducateYour.Video

  def show(conn, %{"id" => video_id}) do
    video = Repo.get!(Video, video_id)
    render conn, "show.html", video: video
  end
end
