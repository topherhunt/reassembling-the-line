defmodule EducateYourWeb.Admin.VideoController do
  use EducateYourWeb, :controller
  alias EducateYour.Videos

  def index(conn, _params) do
    render conn, "index.html", videos: Videos.all_videos_with_preloads
  end
end
