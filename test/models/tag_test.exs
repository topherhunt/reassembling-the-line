defmodule Zb.TagTest do
  use Zb.ModelCase, async: true

  test "validations" do
    tag = build_with_assocs(:tag)
    assert_validates_presence(tag, :admin_changeset, :text)
    assert_validates_presence(tag, :voter_changeset, :text)
    assert_validates_uniqueness(tag, :admin_changeset, :text)
    assert_validates_uniqueness(tag, :voter_changeset, :text)
  end

  test "text is downcased and commas are removed" do
    changeset = Zb.Tag.admin_changeset(%Zb.Tag{}, %{text: "ONE'Two,three"})
    assert changeset |> get_change(:text) == "one'twothree"
    changeset = Zb.Tag.voter_changeset(%Zb.Tag{}, %{text: "ONE'Two,three"})
    assert changeset |> get_change(:text) == "one'twothree"
  end

  test "only admin can set :recommended" do
    tag = %Zb.Tag{recommended: false}
    admin_changeset = Zb.Tag.admin_changeset(tag, %{recommended: true})
    assert get_change(admin_changeset, :recommended) == true
    voter_changeset = Zb.Tag.voter_changeset(tag, %{recommended: true})
    assert get_change(voter_changeset, :recommended) == nil
  end
end
