defmodule RTLWeb.Admin.VideoController do
  use RTLWeb, :controller
  alias RTL.Videos

  def index(conn, _params) do
    render(conn, "index_wrapper.html")
    # render(conn, "index.html",
    #   videos: Videos.all_videos_with_preloads(),
    #   next_uncoded_video: Videos.next_video_to_code()
    # )
    #
    # Phoenix.LiveView.Controller.live_render(...)
    # Phoenix.LiveView.Controller.live_render(conn, RTLWeb.Live.Admin.VideosList, session: %{})
  end

  def delete(conn, %{"id" => video_id}) do
    Videos.get_video!(video_id) |> Videos.delete_video!()

    conn
    |> put_flash(:info, "Video #{video_id} was deleted.")
    |> redirect(to: Routes.admin_video_path(conn, :index, []))
  end
end
