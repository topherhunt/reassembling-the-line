defmodule RTLWeb.Manage.ProjectSettingController do
  use RTLWeb, :controller
  alias RTL.{Projects}

  plug :load_project
  plug :ensure_superadmin
  plug :ensure_valid_field

  def edit(conn, %{"field" => field}) do
    value = (conn.assigns.project.settings || %{})[field]
    type = ProjectSetting.valid_fields[field]
    render conn, "edit.html", field: field, value: value, type: type
  end

  def update(conn, %{"field" => field, "value" => value}) do
    project = conn.assigns.project
    new_settings = update_setting(project, field, value)
    Projects.update_project!(project, %{settings: new_settings})

    conn
    |> put_flash(:info, "Setting updated.")
    |> redirect(to: Routes.manage_project_path(conn, :show, project))
  end

  #
  # Helpers
  #

  defp ensure_valid_field(conn, _) do
    field = conn.params["field"]
    if field in Map.keys(ProjectSetting.valid_fields()) do
      conn
    else
      raise "Unknown field: #{field}"
    end
  end

  defp update_setting(project, field, value) do
    if value == "nil" do
      Map.drop(project.settings || %{}, [field])
    else
      Map.put(project.settings || %{}, field, value)
    end
  end

end
