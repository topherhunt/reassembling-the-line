defmodule RTLWeb.Admin.CustomBlockControllerTest do
  use RTLWeb.ConnCase, async: true

  describe "#index" do
    test "renders", %{conn: conn} do
      {conn, _user} = login_as_superadmin(conn)
      project = Factory.insert_project()

      conn = get(conn, Routes.admin_custom_block_path(conn, :index, project))

      assert html_response(conn, 200) =~ "Manage custom HTML and CSS sections for this project using the blocks below."
    end
  end

  describe "#edit" do
    test "renders the edit page", %{conn: conn} do
      {conn, _user} = login_as_superadmin(conn)
      project = Factory.insert_project()

      conn = get(conn, Routes.admin_custom_block_path(conn, :edit, project, "navbar_logo"))

      assert html_response(conn, 200) =~ "Custom block: <code>navbar_logo</code>"
    end
  end

  describe "#update" do
    @tag :skip
    test "saves your changes", %{conn: _conn} do
      raise "TODO"
    end
  end

  describe "#delete" do
    @tag :skip
    test "removes that CustomBlock", %{conn: _conn} do
      raise "TODO"
    end
  end
end
