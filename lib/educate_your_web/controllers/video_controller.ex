defmodule EducateYourWeb.VideoController do
  use EducateYourWeb, :controller
  alias EducateYour.Repo
  alias EducateYour.Schemas.Video

  def show(conn, %{"id" => video_id}) do
    video = Repo.get!(Video, video_id)
    render conn, "show.html", video: video
  end
end
