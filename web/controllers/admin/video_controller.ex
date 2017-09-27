defmodule EducateYour.Admin.VideoController do
  use EducateYour.Web, :controller
  alias EducateYour.Video

  def index(conn, _params) do
    videos = Video
      |> preload([coding: [:updated_by_user, :tags]])
      |> order_by([v], asc: v.id)
      |> Repo.all
    render conn, "index.html", videos: videos
  end
end
