defmodule RTLWeb.AuthControllerTest do
  use RTLWeb.ConnCase
  alias RTL.Accounts

  setup do
    # Clear all emails sent by previous tests.
    # NOT compatible with async tests.
    Bamboo.SentEmail.reset()
  end

  def ts_now, do: System.system_time(:second)
  def ts_nearly_1h_ago, do: ts_now() - 3595
  def ts_over_1h_ago, do: ts_now() - 3605

  describe "#login" do
    test "renders the login form", %{conn: conn} do
      conn = get(conn, Routes.auth_path(conn, :login))

      assert html_response(conn, 200) =~ "Please enter your email address"
    end
  end

  describe "#login_submit" do
    test "emails a signed login link to the provided address", %{conn: conn} do
      params = %{user: %{email: "elmer.fudd@example.com"}}
      conn = post(conn, Routes.auth_path(conn, :login_submit), params)

      assert redirected_to(conn) == Routes.auth_path(conn, :login)

      [email] = Bamboo.SentEmail.all()
      assert email.subject =~ "Your login link"
      assert email.to == [nil: "elmer.fudd@example.com"]
      assert email.html_body =~ "Please click the link below to log in."

      assert [_, token] = Regex.run(~r/\?token=([\w\d\.\-\_]+)/, email.html_body)
      assert {:ok, "elmer.fudd@example.com"} = Accounts.verify_login_token(token)
    end
  end

  describe "#confirm" do
    test "when valid and user exists: logs you in", %{conn: conn} do
      user = Factory.insert_user(email: "daffy@example.com")

      # User visits the confirm page with a nearly-expired link.
      token = stub_token("Daffy@EXAMPLE.com", ts_nearly_1h_ago())
      conn = get(conn, Routes.auth_path(conn, :confirm, token: token))

      assert redirected_to(conn) == Routes.home_path(conn, :index), "The conn: #{inspect(conn)}"
      assert_logged_in(conn, user)
    end

    # test "when valid and user does not exist: registers & logs you in", %{conn: conn} do
    #   # Token contains a capitalized email, but is registered as lower-cased
    #   token = stub_token("Daisy@EXAMPLE.com", ts_now())
    #   conn = get(conn, Routes.auth_path(conn, :confirm, token: token))

    #   assert user = Accounts.get_user_by!(email: "daisy@example.com")
    #   assert redirected_to(conn) == Routes.user_path(conn, :edit)
    #   assert_logged_in(conn, user)
    # end

    test "when valid and user does not exist: denies access (for now)", %{conn: conn} do
      user_count = Accounts.count_users()

      token = stub_token("daisy@example.com", ts_now())
      conn = get(conn, Routes.auth_path(conn, :confirm, token: token))

      assert Accounts.count_users() == user_count
      assert redirected_to(conn) == Routes.home_path(conn, :index)
      assert_logged_out(conn)
    end

    test "when link is expired: rejects and redirects", %{conn: conn} do
      token = stub_token("Daisy@EXAMPLE.com", ts_over_1h_ago())
      conn = get(conn, Routes.auth_path(conn, :confirm, token: token))

      assert redirected_to(conn) == Routes.auth_path(conn, :login)
      assert_logged_out(conn)
    end

    test "when link is invalid: rejects and redirects", %{conn: conn} do
      token = stub_token("Daisy@EXAMPLE.com", ts_now())
      conn = get(conn, Routes.auth_path(conn, :confirm, token: token<>"z"))

      assert redirected_to(conn) == Routes.auth_path(conn, :login)
      assert_logged_out(conn)
    end
  end

  describe "#logout" do
    test "logs you out of all your sessions", %{conn: conn} do
      user = Factory.insert_user()
      token = stub_token(user.email, ts_now())
      conn = get(conn, Routes.auth_path(conn, :confirm, token: token))
      assert_logged_in(conn, user)

      conn = get(conn, Routes.auth_path(conn, :log_out))

      assert redirected_to(conn) == Routes.home_path(conn, :index)
      assert_logged_out(conn)

      # Login session token has been resets
      old_login_token = user.session_token
      new_login_token = Accounts.get_user!(user.id).session_token
      assert new_login_token != old_login_token
      assert String.length(old_login_token) >= 8
      assert String.length(new_login_token) >= 8
    end
  end

  #
  # Helpers
  #

  defp stub_token(email, signed_at) do
    endpoint = RTLWeb.Endpoint
    Phoenix.Token.sign(endpoint, "login token salt", email, signed_at: signed_at)
  end

  defp assert_logged_in(conn, _user) do
    conn = get(conn, Routes.home_path(conn, :index))
    assert conn.resp_body =~ "Log out"
    refute conn.resp_body =~ "Log in"
  end

  defp assert_logged_out(conn) do
    conn = get(conn, Routes.home_path(conn, :index))
    assert conn.resp_body =~ "Log in"
    refute conn.resp_body =~ "Log out"
  end
end
