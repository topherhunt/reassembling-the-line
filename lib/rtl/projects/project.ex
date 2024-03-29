defmodule RTL.Projects.Project do
  use Ecto.Schema
  import Ecto.Changeset
  require Ecto.Query
  alias Ecto.Query, as: Q
  alias RTL.Repo

  # Tells Router helpers to use project uuid instead of id in all routes.
  @derive {Phoenix.Param, key: :uuid}

  schema "projects" do
    field :name, :string
    field :uuid, :string
    field :settings, :map
    timestamps()

    has_many :project_admin_joins, RTL.Projects.ProjectAdminJoin
    has_many :admins, through: [:project_admin_joins, :admin]
    has_many :prompts, RTL.Projects.Prompt
    has_many :videos, through: [:prompts, :videos]
    has_many :custom_blocks, RTL.Projects.CustomBlock
  end

  #
  # Public API
  #

  # TODO: Remove these in favor of plain Repo calls in context
  def get(id, f \\ []), do: __MODULE__ |> filter([{:id, id} | f]) |> Repo.one()
  def get!(id, f \\ []), do: __MODULE__ |> filter([{:id, id} | f]) |> Repo.one!()
  def first(filters \\ []), do: __MODULE__ |> filter(filters) |> Repo.first()
  def first!(filters \\ []), do: __MODULE__ |> filter(filters) |> Repo.first!()
  def all(filters \\ []), do: __MODULE__ |> filter(filters) |> Repo.all()
  def count(filters \\ []), do: __MODULE__ |> filter(filters) |> Repo.count()

  def changeset(struct, params) do
    struct
    # Allowing setting of uuid for admin convenience
    |> cast(params, [:name, :uuid, :settings])
    |> populate_uuid()
    |> validate_required([:name, :uuid])
    |> unique_constraint(:uuid)
  end

  def populate_uuid(changeset) do
    if get_field(changeset, :uuid),
      do: changeset,
      else: put_change(changeset, :uuid, RTL.Factory.random_uuid())
  end

  #
  # Filters
  #

  def filter(starting_query, filters) do
    Enum.reduce(filters, starting_query, fn {k, v}, query -> filter(query, k, v) end)
  end

  def filter(query, :id, id), do: Q.where(query, [p], p.id == ^id)
  def filter(query, :uuid, uuid), do: Q.where(query, [p], p.uuid == ^uuid)
  def filter(query, :prompt, prom), do: Q.where(query, [p], p.prompt_id == ^prom.id)
  def filter(query, :order, :newest), do: Q.order_by(query, [p], desc: p.id)
  def filter(query, :order, :name), do: Q.order_by(query, [p], asc: p.name)
  def filter(query, :preload, p), do: Q.preload(query, ^p)

  def filter(query, :visible_to, user) do
    if RTL.Sentry.is_superadmin?(user),
      do: query,
      else: filter(query, :having_admin, user)
  end

  def filter(query, :having_admin, user) do
    Q.where(
      query,
      [p],
      fragment(
        "EXISTS (SELECT * FROM project_admin_joins WHERE project_id = ? AND admin_id = ?)",
        p.id,
        ^user.id
      )
    )
  end

  def filter(query, :not_having_admin, user) do
    Q.where(
      query,
      [p],
      fragment(
        "NOT EXISTS (SELECT * FROM project_admin_joins WHERE project_id = ? AND admin_id = ?)",
        p.id,
        ^user.id
      )
    )
  end
end
