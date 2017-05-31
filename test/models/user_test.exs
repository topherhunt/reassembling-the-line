defmodule EducateYour.UserTest do
  use EducateYour.ModelCase, async: true
  alias EducateYour.User

  test "validates required fields" do
    defaults = params_with_assocs(:user)
    assert_valid(User, :changeset, defaults)
    assert_invalid(User, :changeset, defaults, %{email: nil})
    assert_invalid(User, :changeset, defaults, %{full_name: nil})
  end

  test "validates uniqueness of email" do
    other_user = insert :user
    params = params_with_assocs(:user, email: other_user.email)
    changeset = User.changeset(%User{}, params)
    {:error, changeset} = Repo.insert(changeset)
    assert changeset.errors[:email] == {"has already been taken", []}
  end

  test "UUID is automatically populated" do
    user = build(:user, uuid: nil)
    assert user.uuid == nil
    changeset = User.changeset(user, %{})
    assert get_change(changeset, :uuid) != nil
  end
end
