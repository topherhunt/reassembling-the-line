defmodule EducateYour.TagTest do
  use EducateYour.ModelCase, async: true
  alias EducateYour.Tag

  test "validates presence of context and text" do
    defaults = params_with_assocs(:tag)
    assert_valid(Tag, :changeset, defaults)
    assert_invalid(Tag, :changeset, defaults, %{context: nil})
    assert_invalid(Tag, :changeset, defaults, %{text: nil})
  end
end
