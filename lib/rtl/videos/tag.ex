defmodule RTL.Videos.Tag do
  use Ecto.Schema
  import Ecto.Changeset
  require Ecto.Query
  alias Ecto.Query, as: Q
  alias RTL.Repo

  schema "tags" do
    belongs_to :project, RTL.Projects.Project
    field :text, :string
    timestamps()

    has_many :taggings, RTL.Videos.Tagging
  end

  #
  # Public API
  #

  # TODO: Remove the query functions in the context and replace with these
  def get!(id, f \\ []), do: __MODULE__ |> apply_filters([{:id, id} | f]) |> Repo.one!()
  def first(filters \\ []), do: __MODULE__ |> apply_filters(filters) |> Repo.first()
  def all(filters \\ []), do: __MODULE__ |> apply_filters(filters) |> Repo.all()
  def count(filters \\ []), do: __MODULE__ |> apply_filters(filters) |> Repo.count()

  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:text])
    |> validate_required([:text])
    |> validate_tag_has_no_special_chars
  end

  #
  # Validations
  #

  def validate_tag_has_no_special_chars(changeset) do
    text = get_field(changeset, :text)

    if String.match?(text || "", ~r/\A[\w\d \-\_]+\z/) do
      changeset
    else
      add_error(changeset, :text, "Must only contain letters, numbers, and spaces.")
    end
  end

  #
  # Filters
  #

  def apply_filters(starting_query, filters) do
    Enum.reduce(filters, starting_query, fn {k, v}, query -> filter(query, k, v) end)
  end

  def filter(query, :id, id), do: Q.where(query, [t], t.id == ^id)
  def filter(query, :project, proj), do: Q.where(query, [t], t.project_id == ^proj.id)
end
