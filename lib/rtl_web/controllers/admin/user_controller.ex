defmodule RTLWeb.Admin.UserController do
  use RTLWeb, :controller
  alias RTL.{Accounts, Projects}
  alias RTL.Accounts.User

  plug :ensure_superadmin
  plug :load_user when action in [:show, :edit, :update, :delete]

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
    changeset = User.changeset(%User{}, %{}, :owner)
    render conn, "new.html", changeset: changeset
  end

  def create(conn, %{"user" => user_params}) do
    user_params = Map.put(user_params, "confirmed_at", H.now())
    case Accounts.insert_user(user_params, :admin) do
      {:ok, user} ->
        conn
        |> put_flash(:info, gettext("User created."))
        |> redirect(to: Routes.admin_user_path(conn, :show, user.id))

      {:error, changeset} ->
        conn
        |> put_flash(:error, gettext("Please see errors below."))
        |> render("new.html", changeset: changeset)
    end
  end

  def edit(conn, _params) do
    changeset = User.changeset(conn.assigns.user, %{}, :owner)
    render(conn, "edit.html", changeset: changeset)
  end

  def update(conn, %{"user" => user_params}) do
    case Accounts.update_user(conn.assigns.user, user_params, :admin) do
      {:ok, user} ->
        conn
        |> put_flash(:info, gettext("User updated."))
        |> redirect(to: Routes.admin_user_path(conn, :show, user.id))

      {:error, changeset} ->
        conn
        |> put_flash(:error, gettext("Please see errors below."))
        |> render("edit.html", changeset: changeset)
    end
  end

  def delete(conn, _params) do
    Accounts.delete_user!(conn.assigns.user)

    conn
    |> put_flash(:info, gettext("User deleted."))
    |> redirect(to: Routes.admin_user_path(conn, :index))
  end

  #
  # Helpers
  #

  defp load_user(conn, _) do
    id = conn.params["id"]
    assign(conn, :user, Accounts.get_user!(id, preload: :projects))
  end
end
