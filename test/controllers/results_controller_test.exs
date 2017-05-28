defmodule Zb.ResultsControllerTest do
  use Zb.ConnCase, async: true

  test "all actions require a logged-in user", %{conn: conn} do
    [
      get(conn, result_path(conn, :index))
    ] |> Enum.map(fn(conn) ->
      assert redirected_to(conn) == session_path(conn, :new)
      assert conn.halted
    end)
  end

  test "#index renders", %{conn: conn} do
    {conn, _} = login_as_new_user(conn)
    conn = get(conn, result_path(conn, :index))
    assert html_response(conn, 200) =~ "Nothing here yet."
  end
end
