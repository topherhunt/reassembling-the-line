defmodule EducateYour.Schemas.TagTest do
  use EducateYour.DataCase, async: true
  alias EducateYour.Schemas.Tag

  test "validates presence of text" do
    defaults = params_with_assocs(:tag)
    assert_valid(Tag, :changeset, defaults)
    assert_invalid(Tag, :changeset, defaults, %{text: nil})
  end

  test "validates that text contains only alpha + numbers + spaces" do
    defaults = params_with_assocs(:tag)
    assert_valid(Tag, :changeset, defaults, %{text: "123 Tophers house"})
    assert_valid(Tag, :changeset, defaults, %{text: "123-Tophers-house_two_"})
    assert_invalid(Tag, :changeset, defaults, %{text: "123 Topher's house"})
    assert_invalid(Tag, :changeset, defaults, %{text: "#123 Tophers house"})
    assert_invalid(Tag, :changeset, defaults, %{text: "Topher."})
  end
end
