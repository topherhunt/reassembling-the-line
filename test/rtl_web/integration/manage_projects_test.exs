defmodule RTLWeb.ManageProjectsTest do
  use RTLWeb.IntegrationCase
  alias RTL.Projects

  hound_session()

  test "Superadmin can list, create, edit, and delete projects", %{conn: conn} do
    _superadmin = login_as_superadmin(conn)
    _existing_project = Factory.insert_project()

    # Listing projects
    find_element(".test-link-list-projects") |> click()
    assert_selector(".test-page-list-projects")

    # Creating a project
    find_element(".test-link-new-project") |> click()
    find_element("#project_name") |> fill_field("Project 2")
    find_element(".test-submit") |> click()
    project = Projects.get_project_by!(order: :newest)
    assert project.name == "Project 2"

    # Showing the project
    assert_selector(".test-page-show-project-#{project.id}")

    # Editing the project
    find_element(".test-link-edit-project-#{project.id}") |> click()
    find_element("#project_name") |> fill_field("District 9")
    find_element(".test-submit") |> click()
    assert Projects.get_project(project.id).name == "District 9"

    # Deleting the project
    find_element(".test-link-edit-project-#{project.id}") |> click()
    find_element(".test-link-delete-project-#{project.id}") |> click()
    accept_dialog()
    assert_selector(".test-page-list-projects")
    assert Projects.get_project(project.id) == nil
  end

  test "Project admin can list, view, edit, and delete projects", %{conn: conn} do
    user = login_as_new_user(conn)
    project = Factory.insert_project()
    Projects.add_project_admin!(project, user)

    # Listing projects
    find_element(".test-link-list-projects") |> click()
    assert_selector(".test-page-list-projects")

    # Showing the project
    find_element(".test-link-show-project-#{project.id}") |> click()
    assert_selector(".test-page-show-project-#{project.id}")

    # Editing the project
    find_element(".test-link-edit-project-#{project.id}") |> click()
    find_element("#project_name") |> fill_field("District 9")
    find_element(".test-submit") |> click()
    assert Projects.get_project(project.id).name == "District 9"

    # Deleting the project
    find_element(".test-link-edit-project-#{project.id}") |> click()
    find_element(".test-link-delete-project-#{project.id}") |> click()
    accept_dialog()
    assert_selector(".test-page-list-projects")
    assert Projects.get_project(project.id) == nil
  end
end
