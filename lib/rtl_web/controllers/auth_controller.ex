defmodule RTLWeb.AuthController do
  use RTLWeb, :controller
  alias RTL.Accounts
  require Logger

  def login(conn, _params) do
    render conn, "login.html"
  end

  def login_submit(conn, %{"user" => %{"email" => email}}) do
    # We don't look up the user, we simply send a confirmation link to that address.
    # We'll find or create them after we confirm that they control this address.
    # Silently ignores sending failures.
    RTL.Emails.confirm_address(email) |> RTL.Mailer.send()
    msg = gettext("Thanks! We just emailed you a login link. Please check your inbox (%{email}).", email: email)

    conn
    |> put_flash(:info, msg)
    |> redirect(to: Routes.auth_path(conn, :login))
  end

  # The emailed login link directs here.
  # NOTE: This endpoint must only redirect, never render html, for security reasons.
  def confirm(conn, %{"token" => token}) do
    case Accounts.verify_login_token(token) do
      {:ok, email} ->
        # For now we don't support new registrations.
        # user = find_user(email) || register_user(email)
        if user = find_user(email) do
          conn
          |> RTLWeb.AuthPlugs.login!(user)
          |> redirect_after_confirm(user)
        else
          conn
          |> put_flash(:info, "Thanks for your interest in RTL! Please reach out to us (hunt.topher@gmail.com) if you'd like to join our closed beta program.")
          |> redirect(to: Routes.home_path(conn, :index))
        end

      _ ->
        conn
        |> put_flash(:error, gettext("Hmm, that login link is too old. Please try again."))
        |> redirect(to: Routes.auth_path(conn, :login))
    end
  end

  def log_out(conn, _params) do
    if conn.assigns.current_user do
      Accounts.reset_user_sessions(conn.assigns.current_user)
    end

    conn
    |> RTLWeb.AuthPlugs.logout!()
    |> redirect(to: Routes.home_path(conn, :index))
  end

  #
  # Helpers
  #

  defp find_user(email) do
    if user = Accounts.get_user_by(email: email) do
      Logger.info "Logged in existing user #{user.id} (#{user.email})"
      user
    end
  end

  # Registration isn't supported for now
  # defp register_user(email) do
  #   user = Accounts.insert_user!(%{email: email})
  #   Logger.info "Registered new user #{user.id} (#{user.email})"
  #   user
  # end

  defp redirect_after_confirm(conn, user) do
    cond do
      user.name == nil ->
        conn
        |> put_flash(:info, gettext("Please enter your name to complete registration."))
        |> redirect(to: Routes.user_path(conn, :edit))

      return_to = conn.req_cookies["return_to"] ->
        conn
        |> delete_resp_cookie("return_to")
        |> put_flash(:info, gettext("Welcome back!"))
        |> redirect(to: return_to)

      true ->
        conn
        |> put_flash(:info, gettext("Welcome back!"))
        |> redirect(to: Routes.home_path(conn, :index))
    end
  end
end
