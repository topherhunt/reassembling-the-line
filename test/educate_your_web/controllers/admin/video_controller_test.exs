defmodule RTLWeb.Admin.VideoControllerTest do
  use RTLWeb.ConnCase, async: true

  test "all actions require logged-in user", %{conn: conn} do
    [
      get(conn, admin_video_path(conn, :index))
    ]
    |> Enum.each(fn conn ->
      assert redirected_to(conn) == home_path(conn, :index)
      assert conn.halted
    end)
  end

  test "#index renders correctly", %{conn: conn} do
    {conn, _user} = login_as_new_user(conn)
    # Populate some dummy data
    # TODO: Add coding data to a video so it's more realistic
    Factory.insert_video()
    Factory.insert_video()

    conn = get(conn, admin_video_path(conn, :index))
    assert html_response(conn, 200) =~ "Videos"
  end

  test "#index redirects when logged out", %{conn: conn} do
    conn = get(conn, admin_video_path(conn, :index))
    assert redirected_to(conn) == home_path(conn, :index)
  end
end
