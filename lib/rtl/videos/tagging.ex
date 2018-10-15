defmodule RTL.Videos.Tagging do
  use Ecto.Schema
  import Ecto.Changeset

  schema "taggings" do
    belongs_to :coding, RTL.Videos.Coding
    belongs_to :tag, RTL.Videos.Tag
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
    starts_at = get_change(changeset, :starts_at)
    ends_at   = get_change(changeset, :ends_at)

    cond do
      (starts_at == nil) != (ends_at == nil) ->
        changeset |> add_error(:starts_at, "Both starts_at and ends_at must be present if either is present.")
      starts_at != nil && starts_at >= ends_at ->
        changeset |> add_error(:starts_at, "The start time must be earlier than the end time.")
      true ->
        changeset
    end
  end
end
