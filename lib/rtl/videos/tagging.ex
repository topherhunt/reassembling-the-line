defmodule RTL.Videos.Tagging do
  use Ecto.Schema
  import Ecto.Changeset
  require Ecto.Query
  alias Ecto.Query, as: Q
  alias RTL.Repo

  schema "taggings" do
    belongs_to :coding, RTL.Videos.Coding
    belongs_to :tag, RTL.Videos.Tag
    field :starts_at, :float
    field :ends_at, :float
    timestamps()
  end

  #
  # Public API
  #

  # TODO: Remove the query functions in the context and replace with these
  def get!(id, f \\ []), do: __MODULE__ |> apply_filters([{:id, id} | f]) |> Repo.one!()
  def first(filters \\ []), do: __MODULE__ |> apply_filters(filters) |> Repo.first()
  def all(filters \\ []), do: __MODULE__ |> apply_filters(filters) |> Repo.all()
  def count(filters \\ []), do: __MODULE__ |> apply_filters(filters) |> Repo.count()

  def insert(params), do: changeset(%__MODULE__{}, params) |> Repo.insert()
  def insert!(params), do: insert(params) |> Repo.ensure_success()
  def update(struct, params), do: changeset(struct, params) |> Repo.update()
  def update!(struct, params), do: update(struct, params) |> Repo.ensure_success()
  def delete!(struct), do: Repo.delete!(struct)

  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:coding_id, :tag_id, :starts_at, :ends_at])
    |> validate_required([:coding_id, :tag_id])
    |> validate_start_and_end_times
  end

  #
  # Validations
  #

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

  #
  # Filters
  #

  def apply_filters(starting_query, filters) do
    Enum.reduce(filters, starting_query, fn {k, v}, query -> filter(query, k, v) end)
  end

  def filter(query, :id, id), do: Q.where(query, [ti], ti.id == ^id)
  def filter(query, :tag, tag), do: Q.where(query, [ti], ti.tag_id == ^tag.id)
  def filter(query, :coding, coding), do: Q.where(query, [ti], ti.coding_id == ^coding.id)
  def filter(query, :order, :starts_at), do: Q.order_by(query, [ti], asc: ti.starts_at)
end
