defmodule RTLWeb.ManageProjectsTest do
  use RTLWeb.IntegrationCase
  alias RTL.Projects

  hound_session()

  test "Superadmin can list, create, edit, and delete projects", %{conn: _conn} do
    superadmin = login_as_superadmin()
    existing_project = Factory.insert_project()
    Projects.add_project_admin!(superadmin, existing_project)

    # Listing projects
    find_element(".test-link-manage-project-list") |> click()
    assert_selector(".test-page-manage-project-list")

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
    find_element(".test-link-delete-project-#{project.id}") |> click()
    accept_dialog()
    assert_selector(".test-page-manage-project-list")
    assert Projects.get_project(project.id) == nil
  end

  test "Project admin can list, view, edit, and delete projects", %{conn: _conn} do
    user = login_as_new_user()
    project = Factory.insert_project()
    Projects.add_project_admin!(user, project)

    # Listing projects
    find_element(".test-link-manage-project-list") |> click()
    assert_selector(".test-page-manage-project-list")

    # Showing the project
    find_element(".test-link-show-project-#{project.id}") |> click()
    assert_selector(".test-page-show-project-#{project.id}")

    # Editing the project
    find_element(".test-link-edit-project-#{project.id}") |> click()
    find_element("#project_name") |> fill_field("District 9")
    find_element(".test-submit") |> click()
    assert Projects.get_project(project.id).name == "District 9"

    # Deleting the project
    find_element(".test-link-delete-project-#{project.id}") |> click()
    accept_dialog()
    assert_selector(".test-page-manage-project-list")
    assert Projects.get_project(project.id) == nil
  end
end
