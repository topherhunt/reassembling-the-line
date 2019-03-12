defmodule RTLWeb.Admin.VideoController do
  use RTLWeb, :controller
  alias RTL.Videos

  def index(conn, _params) do
    render(conn, "index.html",
      videos: Videos.all_videos_with_preloads(),
      next_uncoded_video: Videos.next_video_to_code()
    )
  end
end
