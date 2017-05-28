defmodule Zb.PageControllerTest do
  use Zb.ConnCase

  test "#index renders", %{conn: conn} do
    conn = get(conn, page_path(conn, :index))
    assert html_response(conn, 200) =~ "This is the beta application."
  end
end
