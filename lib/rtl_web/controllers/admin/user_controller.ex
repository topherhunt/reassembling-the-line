defmodule RTLWeb.Admin.UserController do
  use RTLWeb, :controller
  alias RTL.{Accounts, Projects}

  plug :load_user when action in [:show, :edit, :update, :delete]
  plug :ensure_superadmin

  def index(conn, _params) do
    users = Accounts.get_users(preload: :projects)
    render conn, "index.html", users: users
  end

  def show(conn, _params) do
    user = conn.assigns.user
    addable_projects = Projects.get_projects(not_having_admin: user, order: :name)
    render conn, "show.html", addable_projects: addable_projects
  end

  def new(conn, _params) do
    changeset = Accounts.new_user_changeset()
    render conn, "new.html", changeset: changeset
  end

  def create(conn, %{"user" => user_params}) do
    case Accounts.insert_user(user_params) do
      {:ok, user} ->
        conn
        |> put_flash(:info, "User created.")
        |> redirect(to: Routes.manage_user_path(conn, :show, user.id))

      {:error, changeset} ->
        conn
        |> put_flash(:error, "Please see errors below.")
        |> render("new.html", changeset: changeset)
    end
  end

  def edit(conn, _params) do
    changeset = Accounts.user_changeset(conn.assigns.user)
    render(conn, "edit.html", changeset: changeset)
  end

  def update(conn, %{"user" => user_params}) do
    case Accounts.update_user(conn.assigns.user, user_params) do
      {:ok, user} ->
        conn
        |> put_flash(:info, "User updated.")
        |> redirect(to: Routes.manage_user_path(conn, :show, user.id))

      {:error, changeset} ->
        conn
        |> put_flash(:error, "Please see errors below.")
        |> render("edit.html", changeset: changeset)
    end
  end

  def delete(conn, _params) do
    Accounts.delete_user!(conn.assigns.user)

    conn
    |> put_flash(:info, "User deleted.")
    |> redirect(to: Routes.manage_user_path(conn, :index))
  end

  #
  # Helpers
  #

  defp load_user(conn, _) do
    id = conn.params["id"]
    assign(conn, :user, Accounts.get_user!(id, preload: :projects))
  end
end
