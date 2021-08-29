defmodule RTLWeb.AuthController do
  require Logger
  use RTLWeb, :controller
  alias RTL.{Repo, Accounts}
  alias RTL.Helpers, as: H
  alias RTL.Accounts.User
  alias RTLWeb.AuthPlugs

  def signup(conn, _params) do
    changeset = User.changeset(%User{}, %{}, :owner)
    render conn, "signup.html", changeset: changeset, page_title: gettext("Sign up")
  end

  def signup_submit(conn, %{"user" => user_params}) do
    case Accounts.insert_user(user_params, :owner) do
      {:ok, user} ->
        log :info, "Registered new user #{user.id}."
        RTL.Emails.confirm_address(user, user.email) |> RTL.Mailer.send()

        conn
        |> put_flash(:info, gettext("Thanks for registering! Please check your inbox for a confirmation link."))
        |> redirect(to: Routes.home_path(conn, :index))

      {:error, changeset} ->
        render conn, "signup.html", changeset: changeset, page_title: gettext("Sign up")
    end
  end

  def login(conn, _params) do
    render conn, "login.html", page_title: gettext("Log in")
  end

  def login_submit(conn, %{"user" => %{"email" => email, "password" => password}}) do
    user = User.filter(email: email) |> Repo.one() # may be nil
    pw_correct = Accounts.password_correct?(user, password)
    confirmed = user && user.confirmed_at != nil
    account_locked = Accounts.count_recent_login_tries(email) >= 5

    cond do
      account_locked ->
        log :info, "Login failed: account is locked."
        conn
        |> put_flash(:error, gettext("Your account is locked. Please try again in 15 minutes, or reset your password using the link below."))
        |> redirect(to: Routes.auth_path(conn, :login))

      !pw_correct ->
        log :info, "Login failed: incorrect email or password."
        Accounts.insert_login_try!(email)
        conn
        |> put_flash(:error, gettext("That email or password is incorrect. Please try again."))
        |> redirect(to: Routes.auth_path(conn, :login))

      !confirmed ->
        log :info, "Login failed: user #{user.id} account is not confirmed."
        conn
        |> put_flash(:error, gettext("You need to confirm your email address before you can log in. Please check your inbox, or request a new confirmation link below."))
        |> redirect(to: Routes.auth_path(conn, :request_email_confirm))

      true ->
        log :info, "Logged in user #{user.id}."
        Accounts.clear_login_tries(email)
        conn
        |> RTLWeb.AuthPlugs.login!(user)
        |> put_flash(:info, gettext("Welcome back!"))
        |> redirect_after_login()
    end
  end

  def logout(conn, _params) do
    conn
    |> AuthPlugs.logout!()
    |> redirect(to: Routes.home_path(conn, :index))
  end

  #
  # Email confirmation
  #

  # This displays the "Re-send confirmation link" page
  def request_email_confirm(conn, _params) do
    title = gettext("Confirm your email address")
    render conn, "request_email_confirm.html", page_title: title
  end

  # The user has submitted the "Re-send confirmation link" form
  # NOTE: This allows user enumeration. See https://security.stackexchange.com/q/158075
  def request_email_confirm_submit(conn, %{"user" => %{"email" => email}}) do
    user = User.filter(email: email) |> Repo.one()

    cond do
      user == nil ->
        conn
        |> put_flash(:error, gettext("The email address '%{email}' doesn't exist in our system. Maybe you signed up using a different address?", email: email))
        |> redirect(to: Routes.auth_path(conn, :request_email_confirm))

      user.confirmed_at != nil ->
        conn
        |> put_flash(:error, gettext("This address is already confirmed. Log in below.", email: email))
        |> redirect(to: Routes.auth_path(conn, :login))

      true ->
        RTL.Emails.confirm_address(user, user.email) |> RTL.Mailer.send()
        conn
        |> put_flash(:info, gettext("We've emailed a link to %{email}. Please check your inbox.", email: user.email))
        |> redirect(to: Routes.auth_path(conn, :request_email_confirm))
    end
  end

  # This endpoint can be called either to confirm the user's current email, or to change
  # to a new (and newly confirmed) email.
  def confirm_email(conn, %{"token" => token}) do
    case Accounts.parse_token(token) do
      {:ok, {:confirm_email, user_id, email}} ->
        user = Repo.get!(User, user_id)
        # This can fail in a rare edge case when switching to a just-taken email address.
        Accounts.update_user!(user, %{email: email, confirmed_at: H.now()}, :admin)
        Accounts.invalidate_token!(token)

        conn
        |> AuthPlugs.login!(user)
        |> put_flash(:info, gettext("Thanks! Your email address is confirmed."))
        |> redirect(to: Routes.home_path(conn, :index))

      {:error, _} ->
        conn
        |> put_flash(:error, gettext("That link is no longer valid. Please try again."))
        |> redirect(to: Routes.auth_path(conn, :request_email_confirm))
    end
  end

  #
  # Password resets
  #

  # Displays the form for requesting a password reset link.
  def request_password_reset(conn, _params) do
    title = gettext("Reset your password")
    render conn, "request_password_reset.html", page_title: title
  end

  def request_password_reset_submit(conn, %{"user" => %{"email" => email}}) do
    if user = Repo.one(User.filter(email: email)) do
      RTL.Emails.reset_password(user) |> RTL.Mailer.send()

      conn
      |> put_flash(:info, gettext("We've emailed a link to %{email}. Please check your inbox.", email: user.email))
      |> redirect(to: Routes.auth_path(conn, :request_password_reset))
    else
      # NOTE: Minor privacy hole. This allows checking whether a certain account exists.
      # See https://security.stackexchange.com/q/158075
      conn
      |> put_flash(:error, gettext("The email address '%{email}' doesn't exist in our system. Maybe you signed up using a different address?", email: email))
      |> redirect(to: Routes.auth_path(conn, :request_password_reset))
    end
  end

  # Displays the form for actually resetting your password. (accessed via PW reset link)
  def reset_password(conn, %{"token" => token}) do
    case Accounts.parse_token(token) do
      {:ok, {:reset_password, _user_id}} ->
        # If the pw reset token is valid, we render the form for the user to set a new pw.
        render conn, "reset_password.html",
          token: token,
          changeset: User.changeset(%User{}, %{}, :owner),
          page_title: gettext("Reset your password")

      {:error, _} ->
        conn
        |> put_flash(:error, gettext("That link is no longer valid. Please try again."))
        |> redirect(to: Routes.auth_path(conn, :request_password_reset))
    end
  end

  def reset_password_submit(conn, %{"token" => token, "user" => user_params}) do
    case Accounts.parse_token(token) do
      {:ok, {:reset_password, user_id}} ->
        user =
          Repo.get!(User, user_id)
          |> Map.put(:current_password_not_required, true)

        case Accounts.update_user(user, user_params, :owner) do
          {:ok, _} ->
            Accounts.clear_login_tries(user.email)
            Accounts.invalidate_token!(token)
            conn
            |> put_flash(:info, gettext("Password updated. Please log in."))
            |> redirect(to: Routes.auth_path(conn, :login))

          {:error, changeset} ->
            render conn, "reset_password.html",
              token: token,
              changeset: changeset,
              page_title: gettext("Reset your password")
        end

      {:error, _} ->
        conn
        |> put_flash(:error, gettext("Sorry, something went wrong. Please try again."))
        |> redirect(to: Routes.auth_path(conn, :request_password_reset))
    end
  end

  #
  # Helpers
  #

  defp redirect_after_login(conn) do
    cond do
      return_to = conn.req_cookies["return_to"] ->
        conn
        |> delete_resp_cookie("return_to")
        |> redirect(to: return_to)

      true ->
        conn
        |> redirect(to: Routes.home_path(conn, :index))
    end
  end

  defp log(level, message), do: Logger.log(level, "AuthController: #{message}")
end
