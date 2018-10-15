defmodule RTLWeb.Auth do
  import Plug.Conn, only: [
    assign: 3,
    halt: 1,
    get_session: 2,
    put_session: 3,
    configure_session: 2
  ]
  import Phoenix.Controller, only: [put_flash: 3, redirect: 2]
  import Comeonin.Argon2, only: [checkpw: 2, dummy_checkpw: 0]
  alias RTL.Accounts

  # === Plugs ===

  # Assign current_user to the conn, if a user is logged in
  def load_current_user(conn, _opts) do
    cond do
      current_user_assigned?(conn) ->
        conn
      no_login_session?(conn) ->
        conn |> assign(:current_user, nil)
      session_expired?(conn) ->
        conn |> logout!
      user = load_user_from_session(conn) -> # Must come after the expiration check
        conn
          |> put_session(:expires_at, new_expiration_datetime_string())
          |> assign(:current_user, user)
      true -> # No matching user found
        conn |> logout!
    end
  end

  # Deny access to this page unless a user is logged in
  def must_be_logged_in(conn, _opts) do
    if current_user_assigned?(conn) do
      conn
    else
      conn
        |> put_flash(:error, "You must be logged in to access that page.")
        |> redirect(to: RTLWeb.Router.Helpers.home_path(conn, :index))
        |> halt
    end
  end

  def must_not_be_logged_in(conn, _opts) do
    if current_user_assigned?(conn) do
      conn
        |> put_flash(:error, "You are already logged in.")
        |> redirect(to: RTLWeb.Router.Helpers.home_path(conn, :index))
        |> halt
    else
      conn
    end
  end

  # === Semi-public-facing helpers ===

  # Log in the user from UN and PW if credentials are valid
  def try_login(conn, email, pw, [remember_me: remember_me]) do
    user = Accounts.get_user_by(email: email)
    cond do
      user && checkpw(pw, user.password_hash)
        -> {:ok, login!(conn, user, remember_me: remember_me)}
      user -> # user is found, but pw doesn't match
        {:error, :unauthorized, conn}
      true -> # user isn't found
        dummy_checkpw() # prevent timing attacks that could derive valid emails
        {:error, :not_found, conn}
    end
  end

  # Start a logged-in session for an (already authenticated) user
  def login!(conn, user, [remember_me: remember_me]) do
    Accounts.update_user_signin_timestamp!(user)
    conn
      |> assign(:current_user, user)
      |> put_session(:user_id, user.id)
      |> put_session(:remember_me, "#{!!remember_me}")
      |> put_session(:expires_at, new_expiration_datetime_string())
      |> configure_session(renew: true)
  end

  # To log out, we just nuke the whole (cookie-stored) session.
  def logout!(conn) do
    conn
      |> assign(:current_user, nil)
      |> put_session(:user_id, nil)
      |> configure_session(drop: true)
      # This doesn't halt the conn. Later plugs can decide what response to give.
  end

  # === Internal helpers ===

  defp no_login_session?(conn) do
    get_session(conn, :user_id) == nil
  end

  defp current_user_assigned?(conn) do
    conn.assigns[:current_user] != nil
  end

  defp session_expired?(conn) do
    remember_me = get_session(conn, :remember_me)
    expires_at  = get_session(conn, :expires_at)

    remember_me != "true" && (
      expires_at == nil ||
      Timex.after?(Timex.now, Timex.parse!(expires_at, "{ISO:Extended}"))
    )
  end

  defp load_user_from_session(conn) do
    Accounts.get_user_by(id: get_session(conn, :user_id))
  end

  defp new_expiration_datetime_string do
    Timex.now |> Timex.shift(hours: +1) |> Timex.format!("{ISO:Extended}")
  end
end
