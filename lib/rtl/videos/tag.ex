defmodule RTL.Videos.Tag do
  use Ecto.Schema
  import Ecto.Changeset
  require Ecto.Query
  alias Ecto.Query, as: Q
  alias RTL.Repo

  schema "tags" do
    belongs_to :project, RTL.Projects.Project
    field :name, :string
    field :color, :string
    timestamps()

    has_many :taggings, RTL.Videos.Tagging
  end

  #
  # Public API
  #

  # TODO: Move these back up to the Videos context
  def get(id, f \\ []), do: __MODULE__ |> apply_filters([{:id, id} | f]) |> Repo.one()
  def get!(id, f \\ []), do: __MODULE__ |> apply_filters([{:id, id} | f]) |> Repo.one!()
  def first(filters \\ []), do: __MODULE__ |> apply_filters(filters) |> Repo.first()
  def first!(filters \\ []), do: __MODULE__ |> apply_filters(filters) |> Repo.first!()
  def all(filters \\ []), do: __MODULE__ |> apply_filters(filters) |> Repo.all()
  def count(filters \\ []), do: __MODULE__ |> apply_filters(filters) |> Repo.count()

  def insert(params), do: changeset(%__MODULE__{}, params) |> Repo.insert()
  def insert!(params), do: insert(params) |> Repo.ensure_success()
  def update(struct, params), do: changeset(struct, params) |> Repo.update()
  def update!(struct, params), do: update(struct, params) |> Repo.ensure_success()
  def delete!(struct), do: Repo.delete!(struct)

  #
  # Changesets
  #

  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:project_id, :name, :color])
    |> populate_color()
    |> validate_required([:project_id, :name, :color])
    |> unique_constraint(:project_id_text)
  end

  defp populate_color(changeset) do
    if get_field(changeset, :color) do
      changeset
    else
      put_change(changeset, :color, random_color())
    end
  end

  #
  # Validations
  #

  def random_color do
    ~w(
      #ACE4BC #E4CBBB #E4CCAC #DC44A9 #F4CCBA #CCAC94 #D4C48C
      #04146C #2C4CA4 #3C84FC #7C94F4 #046494 #22A9D4 #7DCAED
      #AC1C34 #EC441C #AC5C5C #740C0C #F19289 #FC0404 #EC2434
      #64349C #AC1CF4 #844CD3 #B483CD #442C64 #BCACF4 #8C4DAE
      #048444 #04E474 #4CBC14 #4C7C6C #045B04 #B4DC1C
      #FCE404 #FCBB04 #FCFC04 #0CAC94 #F4DC44 #E2DC1B #DF9F0D
    ) |> Enum.random()
  end

  #
  # Filters
  #

  def apply_filters(starting_query, filters) do
    Enum.reduce(filters, starting_query, fn {k, v}, query -> filter(query, k, v) end)
  end

  def filter(query, :id, id), do: Q.where(query, [t], t.id == ^id)
  def filter(query, :name, name), do: Q.where(query, [t], t.name == ^name)
  def filter(query, :project, proj), do: Q.where(query, [t], t.project_id == ^proj.id)
  def filter(query, :preload, preloads), do: Q.preload(query, ^preloads)
  def filter(query, :order, :name), do: Q.order_by(query, [t], asc: t.name)
end
