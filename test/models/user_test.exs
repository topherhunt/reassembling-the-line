defmodule Zb.UserTest do
  use Zb.ModelCase, async: true

  alias Zb.User

  test "validations" do
    user = build_with_assocs(:user)
    assert_validates_presence   user, :admin_changeset, :email
    assert_validates_presence   user, :admin_changeset, :full_name
    assert_validates_uniqueness user, :admin_changeset, :email
    assert_validates_presence   user, :admin_changeset, :type
    assert_validates_inclusion  user, :admin_changeset, :type, %{valids: ["admin", "faculty", "student"], invalids: ["zzz"]}
  end

  test "UUID is automatically populated" do
    user = build(:user, uuid: nil)
    assert user.uuid == nil
    changeset = User.admin_changeset(user, %{})
    assert get_change(changeset, :uuid) != nil
  end

  test "stored passwords are hashed" do
    user_params = %{type: "faculty", email: "blah", password: "password2", full_name: "blah", min_votes_needed: 1}
    changeset = User.admin_changeset(%User{}, user_params)
    assert Comeonin.Bcrypt.checkpw("password2", get_change(changeset, :password_hash))
  end

  test "#more_votes_needed? returns true only if I'm not meeting my quota" do
    user = insert :user, min_votes_needed: 2
    insert :vote, user: user
    assert User.more_votes_needed?(user) == true
    insert :vote, user: user
    assert User.more_votes_needed?(user) == false
  end
end
