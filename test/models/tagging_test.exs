defmodule EducateYour.TaggingTest do
  use EducateYour.ModelCase, async: true
  alias EducateYour.Tagging

  test "validates required fields" do
    defaults = params_with_assocs(:tagging)
    assert_valid(Tagging, :changeset, defaults)
    assert_invalid(Tagging, :changeset, defaults, %{coding_id: nil})
    assert_invalid(Tagging, :changeset, defaults, %{tag_id: nil})
  end
end
