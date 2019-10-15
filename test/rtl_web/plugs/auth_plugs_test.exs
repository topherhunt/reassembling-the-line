# TODO: To what extent could I move this test coverage to AuthControllerTest so I don't
# need to test much (if anything) at the plug layer?
defmodule RTLWeb.AuthPlugsTest do
  use RTLWeb.ConnCase, async: true
  alias RTLWeb.AuthPlugs
  alias RTL.Accounts

  defp put_session_expiration(conn, adjustment) do
    expiry = Timex.now() |> Timex.shift(adjustment) |> Timex.format!("{ISO:Extended}")
    put_session(conn, :expires_at, expiry)
  end

  defp assert_logged_out(conn) do
    assert get_session(conn, :user_id) == nil
    assert conn.assigns.current_user == nil
    assert conn.private.plug_session_info == :drop
    # NOTE: Logging out does NOT halt conn.
  end

  setup %{conn: conn} do
    # Sets up standard connection status (flash, session, etc.)
    conn = conn |> bypass_through(RTLWeb.Router, :browser) |> get("/")
    {:ok, %{conn: conn}}
  end

  describe "#load_current_user" do
    test "does nothing if current_user is already assigned", %{conn: conn} do
      conn = assign(conn, :current_user, "blah")
      unchanged_conn = conn

      assert AuthPlugs.load_current_user(conn, nil) == unchanged_conn
    end

    test "does nothing if there's no login session", %{conn: conn} do
      conn = AuthPlugs.load_current_user(conn, nil)

      assert get_session(conn, :user_id) == nil
      assert conn.assigns.current_user == nil
      assert !conn.halted
    end

    test "ends the session if expired", %{conn: conn} do
      conn = put_session(conn, :user_id, "123")
      conn = put_session_expiration(conn, hours: -1)

      conn = AuthPlugs.load_current_user(conn, nil)

      assert_logged_out(conn)
    end

    test "assigns current_user based on user_id", %{conn: conn} do
      user = Factory.insert_user()
      conn = put_session(conn, :user_id, user.id)
      conn = put_session(conn, :session_token, user.session_token)
      conn = put_session_expiration(conn, hours: +1)
      assert user.last_visit_date == nil

      conn = AuthPlugs.load_current_user(conn, nil)

      assert conn.assigns.current_user.id == user.id
      assert Accounts.get_user!(user.id).last_visit_date == Date.utc_today()
    end

    test "logs me out if user_id is invalid", %{conn: conn} do
      user = Factory.insert_user()
      conn = put_session(conn, :user_id, user.id + 999)
      conn = put_session(conn, :session_token, user.session_token)
      conn = put_session_expiration(conn, hours: +1)

      conn = AuthPlugs.load_current_user(conn, nil)

      assert_logged_out(conn)
    end

    test "logs me out if session_token is invalid", %{conn: conn} do
      user = Factory.insert_user()
      conn = put_session(conn, :user_id, user.id)
      conn = put_session(conn, :session_token, user.session_token <> "z")
      conn = put_session_expiration(conn, hours: +1)

      conn = AuthPlugs.load_current_user(conn, nil)

      assert_logged_out(conn)
    end
  end

  describe "#login!" do
    test "logs in this user", %{conn: conn} do
      user = Factory.insert_user()
      assert conn.assigns[:current_user] == nil

      conn = AuthPlugs.login!(conn, user)

      assert conn.assigns.current_user.id == user.id
      assert get_session(conn, :user_id) == user.id
    end
  end

  describe "#logout!" do
    test "drops the whole session", %{conn: conn} do
      user = Factory.insert_user()
      conn = AuthPlugs.login!(conn, user)
      assert get_session(conn, :user_id) == user.id

      conn = AuthPlugs.logout!(conn)

      assert_logged_out(conn)
    end
  end
end
