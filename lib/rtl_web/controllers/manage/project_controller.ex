defmodule RTLWeb.Manage.ProjectController do
  use RTLWeb, :controller
  alias RTL.{Accounts, Projects}

  plug :load_project when action in [:show, :edit, :update, :delete]
  plug :authorize_user when action in [:show, :edit, :update, :delete]

  def index(conn, _params) do
    projects = get_projects(conn)
    render conn, "index.html", projects: projects
  end

  def show(conn, _params) do
    # I thought about making this a LV, but the limited UI needs really don't 
    # justify the added layer. Plain server-rendered CRUD is fine.
    # live_render(conn, RTLWeb.Manage.ProjectShowLiveview,
    #   session: %{current_user: conn.assigns.current_user, id: id})
    project = conn.assigns.project
    addable_admins = Accounts.get_users(not_admin_on_project: project, order: :full_name)
    render conn, "show.html", addable_admins: addable_admins
  end

  def new(conn, _params) do
    changeset = Projects.new_project_changeset()
    render conn, "new.html", changeset: changeset
  end

  def create(conn, %{"project" => project_params}) do
    case Projects.insert_project(project_params) do
      {:ok, project} ->
        Projects.add_project_admin!(project, conn.assigns.current_user)
        conn
        |> put_flash(:info, "Project created.")
        |> redirect(to: Routes.manage_project_path(conn, :show, project.id))

      {:error, changeset} ->
        conn
        |> put_flash(:error, "Please see errors below.")
        |> render("new.html", changeset: changeset)
    end
  end

  def edit(conn, _params) do
    changeset = Projects.project_changeset(conn.assigns.project)
    render conn, "edit.html", changeset: changeset
  end

  def update(conn, %{"project" => project_params}) do
    case Projects.update_project(conn.assigns.project, project_params) do
      {:ok, project} ->
        conn
        |> put_flash(:info, "Project updated.")
        |> redirect(to: Routes.manage_project_path(conn, :show, project.id))

      {:error, changeset} ->
        conn
        |> put_flash(:error, "Please see errors below.")
        |> render("edit.html", changeset: changeset)
    end
  end

  def delete(conn, _params) do
    project = conn.assigns.project
    Projects.delete_project!(project)

    conn
    |> put_flash(:info, "Project deleted.")
    |> redirect(to: Routes.manage_project_path(conn, :index))
  end

  #
  # Helpers
  #

  defp load_project(conn, _) do
    id = conn.params["id"]
    assign(conn, :project, Projects.get_project!(id, preload: :admins))
  end

  defp authorize_user(conn, _) do
    user = conn.assigns.current_user
    project = conn.assigns.project

    if RTL.Sentry.can_view_project?(user, project) do
      conn
    else
      redirect_with_permission_error(conn)
    end
  end

  defp get_projects(conn) do
    Projects.get_projects(visible_to: conn.assigns.current_user)
  end
end
