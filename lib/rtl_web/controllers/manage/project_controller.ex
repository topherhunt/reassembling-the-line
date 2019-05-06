defmodule RTLWeb.Manage.ProjectController do
  use RTLWeb, :controller
  alias RTL.{Accounts, Projects, Videos}

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
    # live_render(conn, RTLWeb.Manage.ProjectShowLiveview,
    #   session: %{current_user: conn.assigns.current_user, id: id})
    project = conn.assigns.project |> RTL.Repo.preload(:admins)
    addable_admins = Accounts.get_users(not_admin_on_project: project, order: :full_name)
    prompts = Projects.get_prompts(project: project)
    count_videos = Videos.count_videos(project: project)
    count_videos_coded = Videos.count_videos(project: project, coded: true)

    render conn, "show.html",
      project: project,
      addable_admins: addable_admins,
      prompts: prompts,
      count_videos: count_videos,
      count_videos_coded: count_videos_coded
  end

  def new(conn, _params) do
    changeset = Projects.new_project_changeset()
    render conn, "new.html", changeset: changeset
  end

  def create(conn, %{"project" => project_params}) do
    case Projects.insert_project(project_params) do
      {:ok, project} ->
        Projects.add_project_admin!(conn.assigns.current_user, project)

        conn
        |> put_flash(:info, "Project created.")
        |> redirect(to: Routes.manage_project_path(conn, :show, project))

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
        |> redirect(to: Routes.manage_project_path(conn, :show, project))

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

  defp get_projects(conn) do
    Projects.get_projects(visible_to: conn.assigns.current_user)
  end
end
