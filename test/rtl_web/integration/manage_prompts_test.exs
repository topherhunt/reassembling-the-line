defmodule RTLWeb.ManagePromptsTest do
  use RTLWeb.IntegrationCase
  alias RTL.Projects

  hound_session()

  test "Project admin can manage a project's prompts", %{conn: conn} do
    user = login_as_new_user(conn)
    project = Factory.insert_project()
    Projects.add_project_admin!(user, project)
    prompt1 = Factory.insert_prompt(%{project_id: project.id})
    prompt2 = Factory.insert_prompt(%{project_id: project.id})

    # Listing prompts
    navigate_to Routes.manage_project_path(conn, :show, project)
    assert_selector(".test-link-show-prompt-#{prompt1.id}")
    assert_selector(".test-link-show-prompt-#{prompt2.id}")

    # Creating a prompt
    find_element(".test-link-new-prompt") |> click()
    find_element("#prompt_html") |> fill_field("What is life about?")
    find_element(".test-submit") |> click()
    prompt3 = Projects.get_prompt_by!(order: :newest)
    assert prompt3.html == "What is life about?"

    # Showing the prompt
    assert_selector(".test-page-show-prompt-#{prompt3.id}")

    # Editing the prompt
    find_element(".test-link-edit-prompt-#{prompt3.id}") |> click()
    find_element("#prompt_html") |> fill_field("Why all the fuss?")
    find_element(".test-submit") |> click()
    assert_selector(".test-page-show-prompt-#{prompt3.id}")
    assert Projects.get_prompt(prompt3.id).html == "Why all the fuss?"

    # Deleting the prompt
    find_element(".test-link-delete-prompt-#{prompt3.id}") |> click()
    accept_dialog()
    assert_selector(".test-page-show-project-#{project.id}")
    assert Projects.get_prompt(prompt3.id) == nil
  end
end
