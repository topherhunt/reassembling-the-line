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

  def filter_query(query, :id, id) do
    from p in query, where: p.id == ^id
  end

  def filter_query(query, :visible_to, user) do
    if RTL.Sentry.is_superadmin?(user),
      do: query,
      else: filter_query(query, :having_admin, user)
  end

  def filter_query(query, :having_admin, user) do
    from p in query,
      join: a in assoc(p, :admins),
      where: a.id == ^user.id
  end

  def filter_query(query, :order, :newest) do
    from p in query, order_by: [desc: :id]
  end
end
