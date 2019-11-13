defmodule RTLWeb.LayoutView do
  use RTLWeb, :view

  def manage_or_view_project_path(conn) do
    project = conn.assigns.project
    current_user = conn.assigns.current_user

    if can_manage_project?(current_user, project),
      do: Routes.admin_project_path(conn, :show, project),
      else: Routes.project_path(conn, :show, project)
  end
end
