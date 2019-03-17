defmodule RTL.Videos.Tagging do
  use Ecto.Schema
  import Ecto.Changeset

  schema "taggings" do
    belongs_to(:coding, RTL.Videos.Coding)
    belongs_to(:tag, RTL.Videos.Tag)
    field(:starts_at, :float)
    field(:ends_at, :float)
    timestamps()
  end

  # === Changesets ===

  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:coding_id, :tag_id, :starts_at, :ends_at])
    |> validate_required([:coding_id, :tag_id])
    |> validate_start_and_end_times
  end

  defp validate_start_and_end_times(changeset) do
    starts_at = get_change(changeset, :starts_at)
    ends_at = get_change(changeset, :ends_at)
    starts_at_is_present = starts_at != nil
    ends_at_is_present = ends_at != nil

    cond do
      starts_at_is_present != ends_at_is_present ->
        add_error(
          changeset,
          :starts_at,
          "Both starts_at and ends_at are required if either one is present."
        )

      starts_at_is_present && starts_at >= ends_at ->
        add_error(changeset, :starts_at, "Start time must be before the end time.")

      true ->
        changeset
    end
  end
end
