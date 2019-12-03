defmodule RTLWeb.SentryPlugsTest do
  use RTLWeb.ConnCase, async: true
  alias RTLWeb.SentryPlugs

  setup %{conn: conn} do
    # Sets up standard connection status (flash, session, etc.)
    conn = conn |> bypass_through(RTLWeb.Router, :browser) |> get("/")
    {:ok, %{conn: conn}}
  end

  describe "#ensure_logged_in" do
    test "does nothing if current_user exists", %{conn: conn} do
      conn = assign(conn, :current_user, "something truthy")

      conn = SentryPlugs.ensure_logged_in(conn, [])

      refute conn.halted
    end

    test "redirects and halts if no current_user", %{conn: conn} do
      conn = SentryPlugs.ensure_logged_in(conn, [])

      assert redirected_to(conn) == Routes.auth_path(conn, :login)
      assert conn.halted
    end
  end

  describe "#ensure_not_logged_in" do
    test "does nothing if no current user", %{conn: conn} do
      conn = SentryPlugs.ensure_not_logged_in(conn, [])

      refute conn.halted
    end

    test "redirects and halts if current_user is present", %{conn: conn} do
      conn = assign(conn, :current_user, %RTL.Accounts.User{id: 1})

      conn = SentryPlugs.ensure_not_logged_in(conn, [])

      assert redirected_to(conn) == Routes.home_path(conn, :index)
      assert conn.halted
    end
  end
end
