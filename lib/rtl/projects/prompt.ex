defmodule RTL.Projects.Prompt do
  use Ecto.Schema
  import Ecto.Changeset
  import Ecto.Query

  # Tells Router helpers to use project uuid instead of id in all routes.
  @derive {Phoenix.Param, key: :uuid}

  schema "prompts" do
    belongs_to :project, RTL.Projects.Project
    field :uuid, :string
    field :html, :string
    timestamps()

    has_many :videos, RTL.Videos.Video
  end

  def changeset(struct, params) do
    struct
    |> cast(params, [:project_id, :html])
    |> validate_required([:project_id, :html])
    |> populate_uuid()
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

  def filter(query, :id, id), do: where(query, [p], p.id == ^id)
  def filter(query, :uuid, uuid), do: where(query, [p], p.uuid == ^uuid)
  def filter(query, :project, proj), do: where(query, [p], p.project_id == ^proj.id)
  def filter(query, :order, :id), do: order_by(query, [p], asc: p.id)
  def filter(query, :order, :newest), do: order_by(query, [p], desc: p.id)
end
