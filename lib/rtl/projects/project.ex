defmodule RTL.Projects.Project do
  use Ecto.Schema
  import Ecto.Changeset

  schema "projects" do
    field :name, :string
    field :uuid, :string
    field :deactivated, :boolean
    timestamps()

    has_many :project_admin_joins, RTL.Projects.ProjectAdminJoin
    has_many :admins, through: [:project_admin_joins, :admin]
  end

  def changeset(struct, params) do
    struct
    |> cast(params, [:name, :deactivated])
    |> populate_uuid()
    |> validate_required([:name, :uuid])
    |> unique_constraint(:uuid)
  end

  def populate_uuid(changeset) do
    if get_field(changeset, :uuid) do
      changeset
    else
      put_change(changeset, :uuid, generate_uuid())
    end
  end

  def generate_uuid do
    pool = String.codepoints("ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz1234567890_-")
    # 5 base64 chars gives us 1B combinations; that's plenty of entropy
    (1..5)
    |> Enum.map(fn(_) -> Enum.random(pool) end)
    |> Enum.join()
  end
end
