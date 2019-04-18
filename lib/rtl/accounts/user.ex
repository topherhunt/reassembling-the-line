defmodule RTL.Accounts.User do
  use Ecto.Schema
  import Ecto.Changeset

  schema "users" do
    field :full_name, :string
    field :email, :string
    field :uuid, :string
    field :auth0_uid, :string
    field :last_signed_in_at, Timex.Ecto.DateTime
    timestamps()

    has_many :project_admin_joins, RTL.Projects.ProjectAdminJoin
    has_many :projects, through: [:project_admin_joins, :project]
  end

  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:full_name, :email, :auth0_uid, :last_signed_in_at])
    |> validate_required([:full_name, :email])
    |> populate_uuid()
    |> unique_constraint(:uuid)
    |> unique_constraint(:email)
    |> unique_constraint(:auth0_uid)
  end

  defp populate_uuid(changeset) do
    if get_field(changeset, :uuid) do
      changeset
    else
      random_uuid = :crypto.strong_rand_bytes(8) |> Base.encode16()
      put_change(changeset, :uuid, random_uuid)
    end
  end
end
