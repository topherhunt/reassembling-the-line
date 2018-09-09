defmodule EducateYourWeb.HomeController do
  use EducateYourWeb, :controller

  def index(conn, _params) do
    render conn, "index.html"
  end
end
