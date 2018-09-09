defmodule EducateYourWeb.Admin.VideoController do
  use EducateYourWeb, :controller
  import Ecto.Query
  alias EducateYour.Repo
  alias EducateYour.Schemas.Video

  def index(conn, _params) do
    videos = Video
      |> preload([coding: [:updated_by_user, :tags]])
      |> order_by([v], asc: v.id)
      |> Repo.all
    render conn, "index.html", videos: videos
  end
end
