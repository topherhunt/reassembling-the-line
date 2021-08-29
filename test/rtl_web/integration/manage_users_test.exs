defmodule RTLWeb.ManageUsersTest do
  use RTLWeb.IntegrationCase
  alias RTL.Accounts.User

  hound_session()

  test "Superadmin can list, create, edit, and delete users", %{conn: _conn} do
    superadmin = login_as_superadmin()
    user1 = insert_user()
    user2 = insert_user()

    # Listing users
    find_element(".test-link-manage-user-list") |> click()

    assert_selector(".test-page-manage-user-list")
    assert_text(superadmin.name)
    assert_text(user1.name)
    assert_text(user2.name)

    # Showing the user
    find_element(".test-user-#{user1.id}-link") |> click()
    assert_selector(".test-page-show-user-#{user1.id}")
    assert_text(user1.name)

    # Editing the user
    find_element(".test-link-edit-user-#{user1.id}") |> click()
    find_element("#user_name") |> fill_field("Bugs McBunny")
    find_element(".test-submit") |> click()
    assert_selector(".test-page-show-user-#{user1.id}")
    assert_text("Bugs McBunny")

    # Deleting the user
    find_element(".test-link-edit-user-#{user1.id}") |> click()
    find_element(".test-link-delete-user-#{user1.id}") |> click()
    accept_dialog()
    assert_selector(".test-page-manage-user-list")
    assert Repo.get(User, user1.id) == nil
  end
end
