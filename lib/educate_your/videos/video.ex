defmodule EducateYour.Videos.Video do
  use Ecto.Schema
  import Ecto.Changeset
  import Ecto.Query
  alias EducateYour.Videos.Video

  schema "videos" do
    field :title, :string
    field :source_name, :string
    field :source_url, :string
    field :recording_filename, :string
    field :thumbnail_filename, :string
    timestamps()

    has_one :coding, EducateYour.Videos.Coding
  end

  def changeset(struct, params \\ %{}) do
    struct
      |> cast(params, [:title, :source_name, :source_url, :recording_filename,
        :thumbnail_filename])
      |> validate_required([:title, :recording_filename, :thumbnail_filename])
  end

  #
  # Query helpers
  #

  def sort_by_newest(query), do: query |> order_by([v], desc: v.inserted_at)

  def preload_tags(query), do: query |> preload(coding: [taggings: :tag])

  def uncoded(query \\ Video) do
    query |> where([v], fragment("NOT EXISTS (SELECT * FROM codings WHERE video_id = ?)", v.id))
  end

  def tagged_with(orig_query \\ Video, tags) do
    # TODO: Assert that tags is a properly-formed list of tags
    Enum.reduce(tags, orig_query, fn(tag, query) ->
      query |> where([v], fragment("EXISTS (
        SELECT * FROM codings c
          JOIN taggings ti ON c.id = ti.coding_id
          JOIN tags t ON ti.tag_id = t.id
        WHERE c.video_id = ? AND t.text = ?)",
        v.id, ^tag[:text]))
    end)
  end
end
