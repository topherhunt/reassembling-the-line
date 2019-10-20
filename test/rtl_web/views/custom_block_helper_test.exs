defmodule RTLWeb.CustomBlockHelperTest do
  use RTLWeb.ConnCase, async: true

  test "each available block's default template renders correctly", %{conn: conn} do
    project = Factory.insert_project()
    project = Map.put(project, :custom_blocks, [])
    user = Factory.insert_user()
    RTL.Projects.add_project_admin!(user, project)
    conn = Plug.Conn.assign(conn, :project, project)
    all_labels = RTL.Projects.CustomBlock.templates() |> Enum.map(& &1.label)

    Enum.each(all_labels, fn label ->
      # Render each custom block to verify that no errors are raised
      RTLWeb.CustomBlockHelpers.custom_block(conn, label)
    end)
  end
end
