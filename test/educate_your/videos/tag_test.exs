# TODO: Move this to a Videos context test
defmodule RTL.Videos.TagTest do
  use RTL.DataCase, async: true
  alias RTL.Videos.Tag

  test "validates presence of text" do
    assert_valid(Tag, :changeset, %{text: "some_text"})
    assert_invalid(Tag, :changeset, %{text: ""})
  end

  test "validates that text contains only alpha + numbers + spaces" do
    assert_valid(Tag, :changeset, %{text: "123 Tophers house"})
    assert_valid(Tag, :changeset, %{text: "123-Tophers-house_two_"})
    assert_invalid(Tag, :changeset, %{text: "123 Topher's house"})
    assert_invalid(Tag, :changeset, %{text: "#123 Tophers house"})
    assert_invalid(Tag, :changeset, %{text: "Topher."})
  end
end
