defmodule EducateYour.VideoControllerTest do
  use EducateYour.ConnCase, async: true

  test "#index renders correctly when logged in", %{conn: conn} do
    # Populate some dummy data
    insert :video
    insert :video

    {conn, _user} = login_as_new_user(conn)
    conn = get(conn, admin_video_path(conn, :index))
    assert html_response(conn, 200) =~ "Videos"
  end

  test "#index redirects when logged out", %{conn: conn} do
    conn = get(conn, admin_video_path(conn, :index))
    assert redirected_to(conn) == home_path(conn, :index)
  end
end
