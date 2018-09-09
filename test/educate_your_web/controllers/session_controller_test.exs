defmodule EducateYourWeb.SessionControllerTest do
  use EducateYourWeb.ConnCase, async: true

  test "#login_from_uuid logs me in if uuid matches", %{conn: conn} do
    user = insert :user
    conn = get(conn, session_path(conn, :login_from_uuid, user.uuid))
    assert redirected_to(conn) == home_path(conn, :index)
    assert_logged_in(conn, user)
  end

  test "#login_from_uuid raises 404 if uuid doesn't match", %{conn: conn} do
    user = insert :user
    assert_error_sent(404, fn ->
      get(conn, session_path(conn, :login_from_uuid, user.uuid <> "9"))
    end)
    assert_not_logged_in(conn)
  end

  test "#delete logs me out", %{conn: conn} do
    user = insert :user, email: "a@b.c"
    conn = get(conn, session_path(conn, :login_from_uuid, user.uuid))
    assert_logged_in(conn, user)
    conn = get(conn, session_path(conn, :logout))
    assert_not_logged_in(conn)
  end

  # Helpers

  defp assert_logged_in(conn, user) do
    conn = get(conn, "/") # make another request
    assert get_session(conn, :user_id) == user.id
  end

  defp assert_not_logged_in(conn) do
    conn = get(conn, "/") # make another request
    assert get_session(conn, :user_id) == nil
  end
end
