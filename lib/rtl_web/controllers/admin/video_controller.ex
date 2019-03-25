defmodule RTLWeb.Admin.VideoController do
  use RTLWeb, :controller
  alias RTL.Videos

  def index(conn, _params) do
    render(conn, "index.html",
      videos: Videos.all_videos_with_preloads(),
      next_uncoded_video: Videos.next_video_to_code()
    )
  end

  def delete(conn, %{"id" => video_id}) do
    Videos.get_video!(video_id) |> Videos.delete_video!()

    conn
    |> put_flash(:info, "Video #{video_id} was deleted.")
    |> redirect(to: admin_video_path(conn, :index))
  end
end
