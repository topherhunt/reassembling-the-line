defmodule RTLWeb.UserController do
  use RTLWeb, :controller
  alias RTL.{Repo, Accounts}
  alias RTL.Accounts.User

  plug :ensure_logged_in

  def edit(conn, _params) do
    user = conn.assigns.current_user
    changeset = User.changeset(user, %{}, :owner)
    conn |> render("edit.html", user: user, changeset: changeset)
  end

  def update(conn, %{"user" => user_params}) do
    user = conn.assigns.current_user
    # user_params = user_params |> Map.take(["name"])

    case Accounts.update_user(user, user_params, :owner) do
      {:ok, _user} ->
        conn
        |> put_flash(:info, gettext("Thanks! Your changes were saved."))
        |> redirect(to: Routes.user_path(conn, :edit))

      {:error, changeset} ->
        render(conn, "edit.html", user: user, changeset: changeset)
    end
  end

  def update_email(conn, %{"user" => %{"email" => email}}) do
    if Repo.count(User.filter(email: String.downcase(email))) == 0 do
      user = conn.assigns.current_user
      RTL.Emails.confirm_address(user, email) |> RTL.Mailer.send()

      conn
      |> put_flash(:info, gettext("We just sent a confirmation link to %{email}. Please check your inbox.", email: email))
      |> redirect(to: Routes.user_path(conn, :edit))
    else
      conn
      |> put_flash(:error, gettext("The email address '%{email}' is already taken.", email: email))
      |> redirect(to: Routes.user_path(conn, :edit))
    end
  end
end
