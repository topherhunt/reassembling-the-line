defmodule EducateYour.VideoTest do
  use EducateYour.ModelCase, async: true
  alias EducateYour.Video

  test "validates required fields" do
    defaults = params_with_assocs(:video)
    assert_valid(Video, :changeset, defaults)
    assert_invalid(Video, :changeset, defaults, %{title: nil})
    assert_invalid(Video, :changeset, defaults, %{recording_filename: nil})
    assert_invalid(Video, :changeset, defaults, %{thumbnail_filename: nil})
  end
end
