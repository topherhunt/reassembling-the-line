defmodule EducateYour.Auth do
  import Plug.Conn # assign/3, halt/1, *_session/*
  import Comeonin.Bcrypt, only: [checkpw: 2, dummy_checkpw: 0]
  import Phoenix.Controller, only: [put_flash: 3, redirect: 2]

  alias EducateYour.{Repo, User}

  # === Plugs ===

  # Assign current_user to the conn, if a user is logged in
  def load_current_user(conn, _opts) do
    cond do
      current_user_already_set?(conn) ->
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
  def require_user(conn, _opts) do
    if conn.assigns.current_user do
      conn
    else
      conn
        |> put_flash(:error, "You must be logged in to access that page.")
        |> redirect(to: EducateYour.Router.Helpers.session_path(conn, :new))
        |> halt
    end
  end

  # Deny access to this page unless a user is an admin
  def require_admin(conn, _opts) do
    if conn.assigns.current_user.admin do
      conn
    else
      conn
        |> put_flash(:error, "You must be an admin to access that page.")
        |> redirect(to: EducateYour.Router.Helpers.page_path(conn, :index))
        |> halt
    end
  end

  # === Semi-public-facing helpers ===

  # Start a logged-in session for an (already authenticated) user
  def login!(conn, user) do
    user |> User.admin_changeset(%{last_signed_in_at: Timex.now}) |> Repo.update!
    conn
      |> assign(:current_user, user)
      |> put_session(:user_id, user.id)
      |> put_session(:expires_at, new_expiration_datetime_string())
      |> configure_session(renew: true)
  end

  # Given a submitted UN and PW, we want to log them in if those creds are valid
  def try_login(conn, email, pw) do
    user = Repo.get_by(User, email: email)
    cond do
      user && checkpw(pw, user.password_hash)
        -> {:ok, login!(conn, user)}
      user ->
        {:error, :unauthorized, conn}
      true ->
        dummy_checkpw() # prevent timing attacks that could derive valid emails
        {:error, :not_found, conn}
    end
  end

  # To log out, we just nuke the whole (cookie-stored) session.
  def logout!(conn) do
    conn
      |> assign(:current_user, nil)
      |> put_session(:user_id, nil)
      |> configure_session(drop: true)
      # TODO: Should this also `halt()` the conn? or is that excessive?
  end

  # === Internal helpers ===

  defp no_login_session?(conn) do
    get_session(conn, :user_id) == nil
  end

  defp current_user_already_set?(conn) do
    conn.assigns[:current_user] != nil
  end

  defp session_expired?(conn) do
    if expires_at = get_session(conn, :expires_at) do
      Timex.after?(Timex.now, Timex.parse!(expires_at, "{ISO:Extended}"))
    else
      true
    end
  end

  defp load_user_from_session(conn) do
    Repo.get(User, get_session(conn, :user_id))
  end

  defp new_expiration_datetime_string do
    Timex.now |> Timex.shift(hours: +2) |> Timex.format!("{ISO:Extended}")
  end
end
