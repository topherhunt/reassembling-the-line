defmodule RTL.Videos.Video do
  use Ecto.Schema
  import Ecto.Changeset
  import Ecto.Query
  alias RTL.Videos.{Video, Coding}

  schema "videos" do
    field :title, :string
    field :source_name, :string
    field :source_url, :string
    # Permission values: "researchers", "public". May be null.
    field :permission, :string
    field :recording_filename, :string
    field :thumbnail_filename, :string
    timestamps()

    has_one :coding, Coding
  end

  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [
      :title,
      :source_name,
      :source_url,
      :permission,
      :recording_filename,
      :thumbnail_filename
    ])
    |> validate_required([:title, :recording_filename, :thumbnail_filename])
    |> validate_inclusion(:permission, ["public", "researchers"])
  end

  #
  # Query helpers
  #

  def sort_by_last_coded(query) do
    query
    |> join(:left, [v], c in assoc(v, :coding))
    |> order_by([v, c],
      asc: fragment("? IS NULL", c.id),
      desc: c.inserted_at,
      asc: v.inserted_at
    )
  end

  def sort_by_oldest(query), do: query |> order_by([v], asc: v.inserted_at)

  def preload_tags(query), do: query |> preload(coding: [taggings: :tag])

  def coded(query \\ Video) do
    query |> where([v], fragment("EXISTS (SELECT * FROM codings WHERE video_id = ?)", v.id))
  end

  def uncoded(query \\ Video) do
    query |> where([v], fragment("NOT EXISTS (SELECT * FROM codings WHERE video_id = ?)", v.id))
  end

  def tagged_with(orig_query \\ Video, tags) do
    Enum.reduce(tags, orig_query, fn tag, query ->
      query |> where([v], fragment("EXISTS (
        SELECT * FROM codings c
          JOIN taggings ti ON c.id = ti.coding_id
          JOIN tags t ON ti.tag_id = t.id
        WHERE c.video_id = ? AND t.text = ?)", v.id, ^tag.text))
    end)
  end
end
