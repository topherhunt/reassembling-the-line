defmodule Zb.AuthTest do
  use Zb.ConnCase, async: true
  alias Zb.Auth

  setup %{conn: conn} do
    # Sets up standard connection status (flash, session, etc.)
    conn = conn |> bypass_through(Zb.Router, :browser) |> get("/")
    {:ok, %{conn: conn}}
  end

  # #load_current_user

  test "#load_current_user does nothing if current_user is already assigned", %{conn: conn} do
    conn = assign(conn, :current_user, "blah")
    unchanged_conn = conn
    assert Auth.load_current_user(conn, nil) == unchanged_conn
  end

  test "#load_current_user does nothing if there's no login session", %{conn: conn} do
    conn = Auth.load_current_user(conn, nil)
    assert get_session(conn, :user_id) == nil
    assert conn.assigns.current_user == nil
    assert ! conn.halted
  end

  test "#load_current_user ends the session if expired", %{conn: conn} do
    conn = put_session(conn, :user_id, "123")
    conn = put_session_expiration(conn, hours: -1)
    conn = Auth.load_current_user(conn, nil)
    assert_logged_out(conn)
  end

  test "#load_current_user assigns current_user based on user_id", %{conn: conn} do
    user = insert :user
    conn = put_session(conn, :user_id, user.id)
    conn = put_session_expiration(conn, hours: +1)
    conn = Auth.load_current_user(conn, nil)
    assert conn.assigns.current_user.id == user.id
  end

  test "#load_current_user logs me out if user_id is invalid", %{conn: conn} do
    user = insert :user
    conn = put_session(conn, :user_id, user.id + 999)
    conn = put_session_expiration(conn, hours: +1)
    conn = Auth.load_current_user(conn, nil)
    assert_logged_out(conn)
  end

  defp put_session_expiration(conn, adjustment) do
    expiry = Timex.now |> Timex.shift(adjustment) |> Timex.format!("{ISO:Extended}")
    put_session(conn, :expires_at, expiry)
  end

  defp assert_logged_out(conn) do
    assert get_session(conn, :user_id) == nil
    assert conn.assigns.current_user == nil
    assert conn.private.plug_session_info == :drop
    # NOTE: Logging out does NOT halt conn.
  end

  # #require_user

  test "#require_user does nothing if current_user exists", %{conn: conn} do
    conn = assign(conn, :current_user, "something truthy")
    conn = Auth.require_user(conn, [])
    refute conn.halted
  end

  test "#require_user redirects and halts if no current_user", %{conn: conn} do
    conn = Auth.require_user(conn, [])
    assert redirected_to(conn) == session_path(conn, :new)
    assert conn.halted
  end

  # #login!

  test "#login! logs in this user", %{conn: conn} do
    user = insert :user
    assert user.last_signed_in_at == nil
    assert conn.assigns[:current_user] == nil
    conn = Auth.login!(conn, user)
    assert conn.assigns.current_user.id == user.id
    assert get_session(conn, :user_id) == user.id
    user = Repo.get!(Zb.User, user.id)
    assert user.last_signed_in_at != nil
  end

  # #try_login

  test "#try_login logs in the user if email and password match", %{conn: conn} do
    user = insert :user
    { code, conn } = Auth.try_login(conn, user.email, user.password)
    assert code == :ok
    assert conn.assigns.current_user.id == user.id
    assert conn |> get_session(:user_id) == user.id
  end

  test "#try_login returns error if password doesn't match", %{conn: conn} do
    user = insert :user
    { code, reason, conn } = Auth.try_login(conn, user.email, "incorrect")
    assert code == :error
    assert reason == :unauthorized
    assert conn.assigns[:current_user] == nil
    assert conn |> get_session(:user_id) == nil
  end

  test "#try_login returns error if un not found", %{conn: conn} do
    user = insert :user
    { code, reason, conn } = Auth.try_login(conn, "bad_username", user.password)
    assert code == :error
    assert reason == :not_found
    assert conn.assigns[:current_user] == nil
    assert conn |> get_session(:user_id) == nil
  end

  # #logout!

  test "#logout! drops the whole session", %{conn: conn} do
    user = insert :user
    conn = Auth.login!(conn, user)
    assert get_session(conn, :user_id) == user.id
    conn = Auth.logout!(conn)
    assert_logged_out(conn)
  end
end
