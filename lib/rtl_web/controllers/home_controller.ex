defmodule RTLWeb.HomeController do
  use RTLWeb, :controller

  def index(conn, _params) do
    demo_project = RTL.Projects.get_project_by(uuid: "demo")
    render(conn, "index.html", demo_project: demo_project)
  end

  def test_error(_conn, _params) do
    raise "Threw up!"
  end
end
