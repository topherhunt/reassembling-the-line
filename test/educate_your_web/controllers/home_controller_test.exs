defmodule EducateYourWeb.HomeControllerTest do
  use EducateYourWeb.ConnCase, async: true

  test "#index renders the page", %{conn: conn} do
    conn = get(conn, home_path(conn, :index))
    assert html_response(conn, 200) =~ "Landing page"
  end
end
