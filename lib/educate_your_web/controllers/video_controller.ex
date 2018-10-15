defmodule EducateYourWeb.VideoController do
  use EducateYourWeb, :controller
  alias EducateYour.Videos

  def show(conn, %{"id" => video_id}) do
    render conn, "show.html", video: Videos.get_video!(video_id)
  end
end
