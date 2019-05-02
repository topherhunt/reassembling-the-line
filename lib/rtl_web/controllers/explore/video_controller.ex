defmodule RTLWeb.Explore.VideoController do
  use RTLWeb, :controller
  alias RTL.Videos

  plug :load_project

  def show(conn, %{"id" => video_id}) do
    video = Videos.get_video!(video_id, project: conn.assigns.project)
    render(conn, "show.html", video: video)
  end
end
