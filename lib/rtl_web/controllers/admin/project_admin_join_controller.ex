defmodule RTLWeb.Admin.ProjectAdminJoinController do
  use RTLWeb, :controller
  alias RTL.{Accounts, Projects}

  plug :ensure_superadmin

  def create(conn, %{"project_id" => project_id, "admin_id" => admin_id}) do
    project = Projects.get_project!(project_id)
    admin = Accounts.get_user!(admin_id)
    Projects.add_project_admin!(project, admin)

    conn
    |> put_flash(:info, "Made #{admin.full_name} admin of project #{project.name}.")
    |> redirect(to: conn.params["return_to"])
  end

  def delete(conn, %{"project_id" => project_id, "admin_id" => admin_id}) do
    project = Projects.get_project!(project_id)
    admin = Accounts.get_user!(admin_id)
    Projects.remove_project_admin!(project, admin)

    conn
    |> put_flash(:info, "Removed #{admin.full_name}'s access to project #{project.name}.")
    |> redirect(to: conn.params["return_to"])
  end
end
