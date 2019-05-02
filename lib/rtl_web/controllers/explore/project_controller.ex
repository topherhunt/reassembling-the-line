defmodule RTLWeb.Explore.ProjectController do
  use RTLWeb, :controller

  plug :load_project

  def show(conn, _params) do
    render(conn, "show.html")
  end
end
