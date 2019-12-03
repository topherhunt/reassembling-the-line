defmodule RTLWeb.Admin.ProjectControllerTest do
  use RTLWeb.ConnCase, async: true
  alias RTL.Projects

  describe "plugs" do
    test "all actions reject if no user is logged in", %{conn: conn} do
      conn = get(conn, Routes.admin_project_path(conn, :index))
      assert redirected_to(conn) == Routes.auth_path(conn, :login)
      assert conn.halted
    end

    test "project-specific actions reject if user isn't admin", %{conn: conn} do
      # I'm logged in, but I'm not an admin on this project
      {conn, _user} = login_as_new_user(conn)
      p = Factory.insert_project()

      [
        get(conn, Routes.admin_project_path(conn, :show, p)),
        get(conn, Routes.admin_project_path(conn, :edit, p)),
        patch(conn, Routes.admin_project_path(conn, :update, p)),
        delete(conn, Routes.admin_project_path(conn, :delete, p))
      ]
      |> Enum.each(fn conn ->
        assert redirected_to(conn) == Routes.home_path(conn, :index)
        assert conn.halted
      end)
    end
  end

  describe "#index" do
    test "lists all projects (for superadmin)", %{conn: conn} do
      {conn, _user} = login_as_new_user(conn, %{email: "superadmin@example.com"})
      project1 = Factory.insert_project()
      project2 = Factory.insert_project()
      project3 = Factory.insert_project()
      admin = Factory.insert_user()
      Projects.add_project_admin!(admin, project1)
      Projects.add_project_admin!(admin, project2)
      Projects.add_project_admin!(admin, project3)

      conn = get(conn, Routes.admin_project_path(conn, :index))

      assert html_response(conn, 200)
      assert conn.resp_body =~ project1.name
      assert conn.resp_body =~ project2.name
      assert conn.resp_body =~ project3.name
    end

    test "lists all projects I'm an admin of (if normal admin)", %{conn: conn} do
      {conn, user} = login_as_new_user(conn)
      project1 = Factory.insert_project()
      project2 = Factory.insert_project()
      project3 = Factory.insert_project()
      # Let's make this person admin of p1 and p3 but NOT p2
      Projects.add_project_admin!(user, project1)
      Projects.add_project_admin!(user, project3)

      conn = get(conn, Routes.admin_project_path(conn, :index))

      assert html_response(conn, 200)
      assert conn.resp_body =~ project1.name
      assert !(conn.resp_body =~ project2.name)
      assert conn.resp_body =~ project3.name
    end
  end

  describe "#show" do
    test "renders the dashboard correctly", %{conn: conn} do
      {conn, user} = login_as_new_user(conn)
      project = Factory.insert_project()
      Projects.add_project_admin!(user, project)

      conn = get(conn, Routes.admin_project_path(conn, :show, project))

      assert html_response(conn, 200) =~ "test-page-show-project-#{project.id}"
    end

    test "renders the dashboard correctly (for superadmin)", %{conn: conn} do
      {conn, _user} = login_as_superadmin(conn)
      project = Factory.insert_project()

      conn = get(conn, Routes.admin_project_path(conn, :show, project))

      assert html_response(conn, 200) =~ "test-page-show-project-#{project.id}"
    end
  end

  describe "#new" do
    test "renders correctly", %{conn: conn} do
      {conn, _} = login_as_superadmin(conn)

      conn = get(conn, Routes.admin_project_path(conn, :new))

      assert html_response(conn, 200) =~ "New project"
    end

    test "non-superadmin can also view the new project form", %{conn: conn} do
      {conn, _} = login_as_new_user(conn)

      conn = get(conn, Routes.admin_project_path(conn, :new))

      assert html_response(conn, 200) =~ "New project"
    end
  end

  describe "#create" do
    test "inserts the project, makes me an admin, and redirects", %{conn: conn} do
      {conn, user} = login_as_superadmin(conn)

      params = %{"project" => %{"name" => "My Little Project"}}
      conn = post(conn, Routes.admin_project_path(conn, :create), params)

      project = Projects.get_project_by!(order: :newest)
      assert project.name == "My Little Project"
      assert Projects.is_project_admin?(user, project)
      assert redirected_to(conn) == Routes.admin_project_path(conn, :show, project)
    end

    test "rejects changes if invalid", %{conn: conn} do
      {conn, _user} = login_as_superadmin(conn)

      params = %{"project" => %{"name" => "   "}}
      conn = post(conn, Routes.admin_project_path(conn, :create), params)

      assert html_response(conn, 200) =~ "name can't be blank"
    end

    test "non-superadmin can create projects too", %{conn: conn} do
      {conn, _} = login_as_new_user(conn)
      projects_count = Projects.count_projects()

      params = %{"project" => %{"name" => "My Little Project"}}
      conn = post(conn, Routes.admin_project_path(conn, :create), params)

      assert Projects.count_projects() == projects_count + 1
      project = Projects.get_projects() |> List.last()
      assert redirected_to(conn) == Routes.admin_project_path(conn, :show, project)
    end
  end

  describe "#edit" do
    test "renders correctly", %{conn: conn} do
      {conn, user} = login_as_new_user(conn)
      project = Factory.insert_project()
      Projects.add_project_admin!(user, project)

      conn = get(conn, Routes.admin_project_path(conn, :edit, project))

      assert html_response(conn, 200) =~ "Edit project: #{project.name}"
    end
  end

  describe "#update" do
    test "saves changes and redirects", %{conn: conn} do
      {conn, user} = login_as_new_user(conn)
      project = Factory.insert_project()
      Projects.add_project_admin!(user, project)

      params = %{"project" => %{"name" => "New name"}}
      conn = patch(conn, Routes.admin_project_path(conn, :update, project), params)

      assert Projects.get_project!(project.id).name == "New name"
      assert redirected_to(conn) == Routes.admin_project_path(conn, :show, project)
    end

    test "rejects changes if invalid", %{conn: conn} do
      {conn, user} = login_as_new_user(conn)
      project = Factory.insert_project()
      Projects.add_project_admin!(user, project)

      params = %{"project" => %{"name" => "        "}}
      conn = patch(conn, Routes.admin_project_path(conn, :update, project), params)

      assert Projects.get_project!(project.id).name == project.name
      assert html_response(conn, 200) =~ "name can't be blank"
    end
  end

  describe "#delete" do
    test "deletes the project", %{conn: conn} do
      {conn, user} = login_as_new_user(conn)
      project = Factory.insert_project()
      Projects.add_project_admin!(user, project)

      conn = delete(conn, Routes.admin_project_path(conn, :delete, project))

      assert Projects.get_project(project.id) == nil
      assert redirected_to(conn) == Routes.admin_project_path(conn, :index)
    end
  end
end
