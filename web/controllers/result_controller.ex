defmodule Zb.ResultController do
  use Zb.Web, :controller

  plug :require_user

  def index(conn, _params) do
    render conn, "index.html"
  end
end
