defmodule RTLWeb.Admin.VideoController do
  use RTLWeb, :controller
  alias RTL.Videos

  def index(conn, _params) do
    render(conn, "index.html", videos: Videos.all_videos_with_preloads())
  end
end
