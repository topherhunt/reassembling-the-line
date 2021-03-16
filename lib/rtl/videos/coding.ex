defmodule RTL.Videos.Coding do
  use Ecto.Schema
  import Ecto.Changeset
  import Ecto.Query

  schema "codings" do
    belongs_to :video, RTL.Videos.Video
    belongs_to :coder, RTL.Accounts.User
    field :completed_at, :utc_datetime
    timestamps()

    has_many(:taggings, RTL.Videos.Tagging)
    has_many(:tags, through: [:taggings, :tag])
  end

  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:video_id, :coder_id, :completed_at])
    |> validate_required([:video_id, :coder_id])
    |> unique_constraint(:video_id)
  end

  #
  # Filters
  #

  def filter(starting_query, filters) do
    Enum.reduce(filters, starting_query, fn {k, v}, query -> filter(query, k, v) end)
  end

  def filter(query, :id, id), do: where(query, [l], l.id == ^id)
  def filter(query, :video, video), do: where(query, [l], l.video_id == ^video.id)
  def filter(query, :preload, preloads), do: preload(query, ^preloads)
end
