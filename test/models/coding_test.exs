defmodule EducateYour.CodingTest do
  use EducateYour.ModelCase, async: true
  alias EducateYour.Coding

  test "validates required fields" do
    defaults = params_with_assocs(:coding)
    assert_valid(Coding, :changeset, defaults)
    assert_invalid(Coding, :changeset, defaults, %{video_id: nil})
    assert_invalid(Coding, :changeset, defaults, %{updated_by_user_id: nil})
  end

  test "validates uniqueness of video_id" do
    other = insert :coding
    params = params_with_assocs(:coding) |> Map.merge(%{video_id: other.video_id})
    changeset = Coding.changeset(%Coding{}, params)
    {:error, changeset} = Repo.insert(changeset)
    assert changeset.errors[:video_id] == {"has already been taken", []}
  end
end
