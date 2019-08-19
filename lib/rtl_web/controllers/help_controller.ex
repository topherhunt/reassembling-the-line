defmodule RTLWeb.HelpController do
  use RTLWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end

  def collecting_videos(conn, _params) do
    render(conn, "collecting_videos.html")
  end

  def coding_page(conn, _params) do
    render(conn, "coding_page.html")
  end
end
