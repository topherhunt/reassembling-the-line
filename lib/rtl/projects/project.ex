defmodule RTL.Projects.Project do
  use Ecto.Schema
  import Ecto.Changeset
  import Ecto.Query

  schema "projects" do
    field :name, :string
    field :uuid, :string
    timestamps()

    has_many :project_admin_joins, RTL.Projects.ProjectAdminJoin
    has_many :admins, through: [:project_admin_joins, :admin]
  end

  def changeset(struct, params) do
    struct
    |> cast(params, [:name])
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

  #
  # Filters
  #

  def filter(starting_query, filters) do
    Enum.reduce(filters, starting_query, fn({k, v}, q) -> filter(q, k, v) end)
  end

  def filter(query, :id, id), do: where(query, [p], p.id == ^id)
  def filter(query, :order, :newest), do: order_by(query, [p], desc: p.id)
  def filter(query, :order, :name), do: order_by(query, [p], asc: p.name)
  def filter(query, :preload, :admins), do: preload(query, :admins)

  def filter(query, :visible_to, user) do
    if RTL.Sentry.is_superadmin?(user),
      do: query,
      else: filter(query, :having_admin, user)
  end

  def filter(query, :having_admin, user) do
    where(query, [p], fragment("EXISTS (SELECT * FROM project_admin_joins WHERE project_id = ? AND admin_id = ?)", p.id, ^user.id))
  end

  def filter(query, :not_having_admin, user) do
    where(query, [p], fragment("NOT EXISTS (SELECT * FROM project_admin_joins WHERE project_id = ? AND admin_id = ?)", p.id, ^user.id))
  end
end
