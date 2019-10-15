defmodule RTLWeb.UserController do
  use RTLWeb, :controller
  alias RTL.Accounts

  plug :ensure_logged_in

  def edit(conn, _params) do
    user = conn.assigns.current_user
    changeset = Accounts.user_changeset(user)
    conn |> render("edit.html", user: user, changeset: changeset)
  end

  def update(conn, %{"user" => user_params}) do
    user = conn.assigns.current_user
    user_params = user_params |> Map.take(["full_name"]) |> Map.put("require_name", true)

    case Accounts.update_user(user, user_params) do
      {:ok, _user} ->
        conn
        |> put_flash(:info, "Thanks! Your changes were saved.")
        |> redirect(to: Routes.home_path(conn, :index))

      {:error, changeset} ->
        conn
        |> put_flash(:error, "Unable to save your changes. Please see errors below.")
        |> render("edit.html", user: user, changeset: changeset)
    end
  end
end
