defmodule RTLWeb.Manage.ProjectSettingControllerTest do
  use RTLWeb.ConnCase, async: true
  alias RTL.Projects

  describe "plugs" do
    test "rejects if not superadmin", %{conn: conn} do
      {conn, user} = login_as_new_user(conn)
      p = Factory.insert_project()
      # It rejects me even if I'm an admin
      Projects.add_project_admin!(user, p)

      conn = get(conn, Routes.manage_project_setting_path(conn, :edit, p, "project_intro_page"))

      assert redirected_to(conn) == Routes.home_path(conn, :index)
      assert conn.halted
    end

    test "rejects if the field name isn't valid", %{conn: conn} do
      {conn, _user} = login_as_superadmin(conn)
      p = Factory.insert_project()

      assert_raise(RuntimeError, fn ->
        get(conn, Routes.manage_project_setting_path(conn, :edit, p, "unknown_field"))
      end)
    end
  end

  describe "#edit" do
    test "renders correctly", %{conn: conn} do
      {conn, _user} = login_as_superadmin(conn)
      project = Factory.insert_project()

      conn = get(conn, edit_path(conn, project))

      assert conn.resp_body =~ "test-manage-project-setting-edit-path"
      assert conn.resp_body =~ "project_intro_page"
    end
  end

  describe "#update" do
    test "saves the setting and redirects", %{conn: conn} do
      {conn, _user} = login_as_superadmin(conn)
      project = Factory.insert_project()

      conn = patch(conn, update_path(conn, project), %{"value" => "new value"})

      assert Projects.get_project!(project.id).settings["project_intro_page"] == "new value"
      assert redirected_to(conn) == Routes.manage_project_path(conn, :show, project)
    end

    test "allows resetting to  default", %{conn: conn} do
      {conn, _user} = login_as_superadmin(conn)
      project = Factory.insert_project()

      conn = patch(conn, update_path(conn, project), %{"value" => "nil"})

      assert Projects.get_project!(project.id).settings == %{}
      assert redirected_to(conn) == Routes.manage_project_path(conn, :show, project)
    end
  end

  defp edit_path(conn, project) do
    Routes.manage_project_setting_path(conn, :edit, project, "project_intro_page")
  end

  defp update_path(conn, project) do
    Routes.manage_project_setting_path(conn, :update, project, "project_intro_page")
  end
end
