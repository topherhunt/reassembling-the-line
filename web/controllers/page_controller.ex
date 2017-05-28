defmodule Zb.PageController do
  use Zb.Web, :controller
  alias Zb.{Repo, User}

  def index(conn, _params) do
    faculty = User
      |> where([u], u.type == "faculty")
      |> order_by([u], asc: u.email)
      |> Repo.all
    render conn, "index.html", faculty: faculty
  end
end
