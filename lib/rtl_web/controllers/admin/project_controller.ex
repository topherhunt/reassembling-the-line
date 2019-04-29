defmodule RTLWeb.Admin.ProjectController do
  use RTLWeb, :controller
  alias RTL.{Accounts, Projects}

  # Rename :uuid to :project_uuid for consistency
  plug :rename_project_uuid when action in [:show, :edit, :update, :delete]
  plug :load_project when action in [:show, :edit, :update, :delete]
  plug :ensure_can_manage_project when action in [:show, :edit, :update, :delete]
  plug :ensure_superadmin when action in [:new, :create]

  def index(conn, _params) do
    projects = get_projects(conn)
    render conn, "index.html", projects: projects
  end

  def show(conn, _params) do
    # I thought about making this a LV, but the limited UI needs really don't
    # justify the added layer. Plain server-rendered CRUD is fine.
    # live_render(conn, RTLWeb.Admin.ProjectShowLiveview,
    #   session: %{current_user: conn.assigns.current_user, id: id})
    project = conn.assigns.project
    addable_admins = Accounts.get_users(not_admin_on_project: project, order: :full_name)
    prompts = Projects.get_prompts(project: project)
    render conn, "show.html", addable_admins: addable_admins, prompts: prompts
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
    Projects.delete_project!(conn.assigns.project)

    conn
    |> put_flash(:info, "Project deleted.")
    |> redirect(to: Routes.manage_project_path(conn, :index))
  end

  #
  # Helpers
  #

  defp rename_project_uuid(conn, _) do
    Map.put_in(conn, [:params, "project_uuid"], conn.params["uuid"])
  end

  defp get_projects(conn) do
    Projects.get_projects(visible_to: conn.assigns.current_user)
  end
end
