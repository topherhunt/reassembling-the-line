defmodule RTL.Videos.Coding do
  use Ecto.Schema
  import Ecto.Changeset
  require Ecto.Query
  alias Ecto.Query, as: Q
  alias RTL.Repo

  schema "codings" do
    belongs_to :video, RTL.Videos.Video
    belongs_to :coder, RTL.Accounts.User
    timestamps()
    field :completed_at, :utc_datetime

    has_many(:taggings, RTL.Videos.Tagging)
    has_many(:tags, through: [:taggings, :tag])
  end

  #
  # Public
  #

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
    |> cast(params, [:video_id, :coder_id, :completed_at])
    |> validate_required([:video_id, :coder_id])
    |> unique_constraint(:video_id)
  end

  #
  # Filters
  #

  def apply_filters(starting_query, filters) do
    Enum.reduce(filters, starting_query, fn {k, v}, query -> filter(query, k, v) end)
  end

  def filter(query, :id, id), do: Q.where(query, [l], l.id == ^id)
  def filter(query, :video, video), do: Q.where(query, [l], l.video_id == ^video.id)
  def filter(query, :preload, preloads), do: Q.preload(query, ^preloads)
end
