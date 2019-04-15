defmodule RTLWeb.Admin.VideoController do
  use RTLWeb, :controller
  alias RTL.Videos

  def index(conn, _params) do
    # Instead of rendering a normal view template, we render a Liveview here.
    # The Liveview process is responsible for fetching all needed data.
    live_render(conn, RTLWeb.Admin.VideosListLiveview, session: %{})
  end

  # The delete action is no longer relevant. The Liveview manages deletion.
  # def delete(conn, %{"id" => video_id}) do
  #   Videos.get_video!(video_id) |> Videos.delete_video!()

  #   conn
  #   |> put_flash(:info, "Video #{video_id} was deleted.")
  #   |> redirect(to: Routes.admin_video_path(conn, :index, []))
  # end
end
