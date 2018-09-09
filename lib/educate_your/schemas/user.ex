defmodule EducateYour.Schemas.User do
  use Ecto.Schema
  import Ecto.Changeset

  schema "users" do
    field :full_name, :string
    field :email, :string # unique indexed
    field :uuid, :string # unique indexed
    field :last_signed_in_at, Timex.Ecto.DateTime # UTC
    timestamps()
  end

  # === Changesets ===

  def changeset(struct, params \\ %{}) do
    struct
      |> cast(params, [:full_name, :email, :last_signed_in_at])
      |> validate_required([:full_name, :email])
      |> unique_constraint(:email)
      |> populate_uuid(struct)
      |> unique_constraint(:uuid)
  end

  defp populate_uuid(changeset, struct) do
    if struct.uuid do
      changeset
    else
      random_uuid = :crypto.strong_rand_bytes(8) |> Base.encode16
      put_change(changeset, :uuid, random_uuid)
    end
  end
end
