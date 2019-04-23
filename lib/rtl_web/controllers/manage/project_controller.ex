defmodule RTLWeb.Manage.ProjectController do
  use RTLWeb, :controller
  alias RTL.Projects

  plug :load_project when action in [:show, :edit, :update, :delete]
  plug :authorize_user when action in [:show, :edit, :update, :delete]

  def index(conn, _params) do
    projects = get_projects(conn)
    render conn, "index.html", projects: projects
  end

  def show(conn, _params) do
    # Even Show will be a static route for now. Most of this CRUD stuff just
    # doesn't need the added layers of LV.
    # live_render(conn, RTLWeb.Manage.ProjectShowLiveview,
    #   session: %{current_user: conn.assigns.current_user, id: id})
    render conn, "show.html", project: conn.assigns.project
  end

  def new(conn, _params) do
    changeset = Projects.new_project_changeset()
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"project" => project_params}) do
    case Projects.insert_project(project_params) do
      {:ok, project} ->
        Projects.insert_project_admin_join!(project, conn.assigns.current_user)
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
    project = conn.assigns.project
    changeset = Projects.project_changeset(project)
    render(conn, "edit.html", project: project, changeset: changeset)
  end

  def update(conn, %{"project" => project_params}) do
    project = conn.assigns.project
    case Projects.update_project(project, project_params) do
      {:ok, _project} ->
        conn
        |> put_flash(:info, "Your changes were saved.")
        |> redirect(to: Routes.manage_project_path(conn, :show, project.id))

      {:error, changeset} ->
        conn
        |> put_flash(:error, "Please see errors below.")
        |> render("edit.html", project: project, changeset: changeset)
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
    assign(conn, :project, Projects.get_project!(id))
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
