defmodule RTLWeb.CustomBlockHelperTest do
  use RTLWeb.ConnCase, async: true
  import RTLWeb.CustomBlockHelpers, only: [custom_block: 2]

  test "each available block's default template renders correctly", %{conn: conn} do
    project = Factory.insert_project()
    project = Map.put(project, :custom_blocks, [])
    user = Factory.insert_user()
    RTL.Projects.add_project_admin!(user, project)
    conn = Plug.Conn.assign(conn, :project, project)
    all_labels = RTL.Projects.CustomBlock.templates() |> Enum.map(& &1.label)

    Enum.each(all_labels, fn label ->
      # Render each custom block to verify that no errors are raised
      custom_block(conn, label)
    end)
  end

  test "variable {ADMIN_LOGIN_URL} works as expected", %{conn: conn} do
    project = Factory.insert_project()
    user = Factory.insert_user()
    RTL.Projects.add_project_admin!(user, project)
    block = %{label: "landing_page", body: "<a href=\"{ADMIN_LOGIN_URL}\">Login</a>"}
    project = Map.put(project, :custom_blocks, [block])
    conn = Plug.Conn.assign(conn, :project, project)

    result = custom_block(conn, "landing_page") |> Phoenix.HTML.safe_to_string()

    assert result =~ ~r(<a href="http://localhost:\d+/auth/confirm\?token=[\w\.\-]+">Login</a>)
  end
end
