defmodule RTLWeb.Manage.ProjectControllerTest do
  use RTLWeb.ConnCase, async: true
  alias RTL.Projects

  test "all actions require logged-in user", %{conn: conn} do
    [
      get(conn, Routes.manage_project_path(conn, :index)),
      get(conn, Routes.manage_project_path(conn, :show, "123")),
      get(conn, Routes.manage_project_path(conn, :new)),
      post(conn, Routes.manage_project_path(conn, :create)),
      get(conn, Routes.manage_project_path(conn, :edit, "123")),
      patch(conn, Routes.manage_project_path(conn, :update, "123")),
      delete(conn, Routes.manage_project_path(conn, :delete, "123"))
    ]
    |> Enum.each(fn conn ->
      assert redirected_to(conn) == Routes.home_path(conn, :index)
      assert conn.halted
    end)
  end

  describe "#index" do
    test "lists all projects (for superadmin)", %{conn: conn} do
      {conn, _user} = login_as_new_user(conn, %{email: "superadmin@example.com"})
      project1 = Factory.insert_project()
      project2 = Factory.insert_project()
      project3 = Factory.insert_project()

      conn = get(conn, Routes.manage_project_path(conn, :index))

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
      Factory.insert_project_admin_join(project1, user)
      Factory.insert_project_admin_join(project3, user)

      conn = get(conn, Routes.manage_project_path(conn, :index))

      assert html_response(conn, 200)
      assert conn.resp_body =~ project1.name
      assert !(conn.resp_body =~ project2.name)
      assert conn.resp_body =~ project3.name
    end
  end

  describe "#show" do
    test "renders correctly", %{conn: conn} do
      {conn, user} = login_as_new_user(conn)
      project = Factory.insert_project()
      Factory.insert_project_admin_join(project, user)

      conn = get(conn, Routes.manage_project_path(conn, :show, project))

      assert html_response(conn, 200) =~ project.name
    end

    test "rejects non-admin", %{conn: conn} do
      {conn, _user} = login_as_new_user(conn)
      project = Factory.insert_project()

      conn = get(conn, Routes.manage_project_path(conn, :show, project))

      assert redirected_to(conn) == Routes.home_path(conn, :index)
    end
  end

  describe "#new" do
    test "renders correctly", %{conn: conn} do
      {conn, _} = login_as_new_user(conn)

      conn = get(conn, Routes.manage_project_path(conn, :new))

      assert html_response(conn, 200) =~ "New project"
    end
  end

  describe "#create" do
    test "inserts the project, makes me an admin, and redirects", %{conn: conn} do
      {conn, user} = login_as_new_user(conn)

      params = %{"project" => %{"name" => "My Little Project"}}
      conn = post(conn, Routes.manage_project_path(conn, :create), params)

      project = Projects.first_project!(order: :newest)
      assert project.name == "My Little Project"
      assert Projects.is_user_admin_of_project?(user, project)
      assert redirected_to(conn) == Routes.manage_project_path(conn, :show, project.id)
    end

    test "rejects changes if invalid", %{conn: conn} do
      {conn, _user} = login_as_new_user(conn)

      params = %{"project" => %{"name" => "   "}}
      conn = post(conn, Routes.manage_project_path(conn, :create), params)

      assert html_response(conn, 200) =~ "name can't be blank"
    end
  end

  describe "#edit" do
    test "renders correctly", %{conn: conn} do
      {conn, user} = login_as_new_user(conn)
      project = Factory.insert_project()
      Factory.insert_project_admin_join(project, user)

      conn = get(conn, Routes.manage_project_path(conn, :edit, project))

      assert html_response(conn, 200) =~ "Edit project: #{project.name}"
    end

    test "rejects if I'm not a project admin", %{conn: conn} do
      {conn, _user} = login_as_new_user(conn)
      project = Factory.insert_project()

      conn = get(conn, Routes.manage_project_path(conn, :edit, project))

      assert redirected_to(conn) == Routes.home_path(conn, :index)
    end
  end

  describe "#update" do
    test "saves changes and redirects", %{conn: conn} do
      {conn, user} = login_as_new_user(conn)
      project = Factory.insert_project()
      Factory.insert_project_admin_join(project, user)

      params = %{"project" => %{"name" => "New name"}}
      conn = patch(conn, Routes.manage_project_path(conn, :update, project.id), params)

      assert Projects.get_project!(project.id).name == "New name"
      assert redirected_to(conn) == Routes.manage_project_path(conn, :show, project)
    end

    test "rejects if I'm not a project admin", %{conn: conn} do
      {conn, _user} = login_as_new_user(conn)
      project = Factory.insert_project()

      params = %{"project" => %{"name" => "New name"}}
      conn = patch(conn, Routes.manage_project_path(conn, :update, project), params)

      assert Projects.get_project!(project.id).name == project.name
      assert redirected_to(conn) == Routes.home_path(conn, :index)
    end

    test "rejects changes if invalid", %{conn: conn} do
      {conn, user} = login_as_new_user(conn)
      project = Factory.insert_project()
      Factory.insert_project_admin_join(project, user)

      params = %{"project" => %{"name" => "        "}}
      conn = patch(conn, Routes.manage_project_path(conn, :update, project), params)

      assert Projects.get_project!(project.id).name == project.name
      assert html_response(conn, 200) =~ "name can't be blank"
    end
  end

  describe "#delete" do
    test "deletes the project", %{conn: conn} do
      {conn, user} = login_as_new_user(conn)
      project = Factory.insert_project()
      Factory.insert_project_admin_join(project, user)

      conn = delete(conn, Routes.manage_project_path(conn, :delete, project))

      assert Projects.get_project(project.id) == nil
      assert redirected_to(conn) == Routes.manage_project_path(conn, :index)
    end

    test "rejects if I'm not a project admin", %{conn: conn} do
      {conn, _user} = login_as_new_user(conn)
      project = Factory.insert_project()

      conn = delete(conn, Routes.manage_project_path(conn, :delete, project))

      assert Projects.get_project(project.id) != nil
      assert redirected_to(conn) == Routes.home_path(conn, :index)
    end
  end
end
