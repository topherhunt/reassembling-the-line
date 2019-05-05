defmodule RTLWeb.ManageUsersTest do
  use RTLWeb.IntegrationCase
  alias RTL.Accounts

  hound_session()

  test "Superadmin can list, create, edit, and delete users", %{conn: conn} do
    superadmin = login_as_superadmin(conn)
    user2 = Factory.insert_user()

    # Listing users
    find_element(".test-link-manage-user-list") |> click()

    assert_selector(".test-page-manage-user-list")
    assert_text(superadmin.full_name)
    assert_text(user2.full_name)

    # Creating a user
    find_element(".test-link-new-user") |> click()
    find_element("#user_full_name") |> fill_field("Bugs Bunny")
    find_element("#user_email") |> fill_field("bugs@bunny.com")
    find_element(".test-submit") |> click()
    user3 = Accounts.get_user_by!(order: :newest)

    # Showing the user
    assert_selector(".test-page-show-user-#{user3.id}")
    assert_text("Bugs Bunny")

    # Editing the user
    find_element(".test-link-edit-user-#{user3.id}") |> click()
    find_element("#user_full_name") |> fill_field("Bugs McBunny")
    find_element(".test-submit") |> click()
    assert_selector(".test-page-show-user-#{user3.id}")
    assert_text("Bugs McBunny")

    # Deleting the user
    find_element(".test-link-edit-user-#{user3.id}") |> click()
    find_element(".test-link-delete-user-#{user3.id}") |> click()
    accept_dialog()
    assert_selector(".test-page-manage-user-list")
    assert Accounts.get_user(user3.id) == nil
  end
end
