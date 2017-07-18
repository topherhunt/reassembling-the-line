defmodule EducateYour.Tagging do
  use EducateYour.Web, :model
  alias EducateYour.H

  schema "taggings" do
    belongs_to :coding, EducateYour.Coding
    belongs_to :tag, EducateYour.Tag
    field :starts_at, :integer
    field :ends_at, :integer
    timestamps()
  end

  # === Changesets ===

  def changeset(struct, params \\ %{}) do
    struct
      |> cast(params, [:coding_id, :tag_id, :starts_at, :ends_at])
      |> validate_required([:coding_id, :tag_id])
      |> validate_start_and_end_must_be_paired
  end

  defp validate_start_and_end_must_be_paired(changeset) do
    if H.is_blank?(get_change(changeset, :starts_at)) != H.is_blank?(get_change(changeset, :ends_at)) do
      add_error(changeset, :starts_at, "Both starts_at and ends_at must be present if either is present.")
    else
      changeset
    end
  end
end
