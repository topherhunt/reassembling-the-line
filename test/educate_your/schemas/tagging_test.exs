defmodule EducateYour.Schemas.TaggingTest do
  use EducateYour.DataCase, async: true
  alias EducateYour.Schemas.Tagging

  test "validates required fields" do
    defaults = params_with_assocs(:tagging)
    assert_valid(Tagging, :changeset, defaults)
    assert_invalid(Tagging, :changeset, defaults, %{coding_id: nil})
    assert_invalid(Tagging, :changeset, defaults, %{tag_id: nil})
  end

  test "validates that start & end must both, or neither, be present" do
    defaults = params_with_assocs(:tagging)
    assert_valid(Tagging, :changeset, defaults, %{starts_at: nil, ends_at: nil})
    assert_invalid(Tagging, :changeset, defaults, %{starts_at: 15})
    assert_invalid(Tagging, :changeset, defaults, %{ends_at: 30})
    assert_valid(Tagging, :changeset, defaults, %{starts_at: 15, ends_at: 30})
  end

  test "validates that start time must be before end time" do
    defaults = params_with_assocs(:tagging)
    assert_valid(Tagging, :changeset, defaults, %{starts_at: 15, ends_at: 16})
    assert_invalid(Tagging, :changeset, defaults, %{starts_at: 16, ends_at: 15})
  end
end
