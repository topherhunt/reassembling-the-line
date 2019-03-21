defmodule RTLWeb.Collect.HubController do
  use RTLWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
