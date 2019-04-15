defmodule RTLWeb.HomeControllerTest do
  use RTLWeb.ConnCase, async: true

  test "#index renders the page", %{conn: conn} do
    conn = get(conn, Routes.home_path(conn, :index))
    assert html_response(conn, 200) =~ "bring personal storytelling back"
  end
end
