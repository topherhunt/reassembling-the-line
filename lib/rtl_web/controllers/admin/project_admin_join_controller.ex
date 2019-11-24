defmodule RTLWeb.Admin.ProjectAdminJoinController do
  use RTLWeb, :controller
  alias RTL.{Accounts, Projects}

  plug :ensure_superadmin

  def create(conn, %{"project_id" => project_id, "admin_id" => admin_id}) do
    project = Projects.get_project!(project_id)
    admin = Accounts.get_user!(admin_id)
    Projects.add_project_admin!(admin, project)

    conn
    |> put_flash(:info, gettext("%{admin} is now an admin on \"%{project}\".", admin: admin.name, project: project.name))
    |> redirect(to: conn.params["return_to"])
  end

  def delete(conn, %{"project_id" => project_id, "admin_id" => admin_id}) do
    project = Projects.get_project!(project_id)
    admin = Accounts.get_user!(admin_id)
    Projects.remove_project_admin!(admin, project)

    conn
    |> put_flash(:info, gettext("Removed %{admin}'s access to project %{project}.", admin: admin.name, project: project.name))
    |> redirect(to: conn.params["return_to"])
  end
end
