defmodule Zb.Admin.DashboardController do
  use Zb.Web, :controller

  def index(conn, _params) do
    render conn, "index.html"
  end
end
