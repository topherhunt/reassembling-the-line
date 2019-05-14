defmodule RTL.Videos.Video do
  use Ecto.Schema
  import Ecto.Changeset
  import Ecto.Query

  schema "videos" do
    belongs_to :prompt, RTL.Projects.Prompt
    field :title, :string
    field :source_name, :string
    field :source_url, :string
    # Permission values: "researchers", "public". May be null.
    field :permission, :string
    field :recording_filename, :string
    field :thumbnail_filename, :string
    timestamps()

    has_one :coding, RTL.Videos.Coding
    has_many :taggings, through: [:coding, :taggings]
    has_many :tags, through: [:coding, :tags]
  end

  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [
      :prompt_id,
      :title,
      :source_name,
      :source_url,
      :permission,
      :recording_filename,
      :thumbnail_filename
    ])
    |> validate_required([:prompt_id, :title, :recording_filename, :thumbnail_filename])
    |> validate_inclusion(:permission, ["public", "researchers"])
  end

  #
  # Query helpers
  #

  def filter(starting_query, filters) do
    Enum.reduce(filters, starting_query, fn {k, v}, query -> filter(query, k, v) end)
  end

  def filter(query, :id, id), do: where(query, [v], v.id == ^id)
  def filter(query, :source_url, url), do: where(query, [v], v.source_url == ^url)
  def filter(query, :prompt, prompt), do: where(query, [v], v.prompt_id == ^prompt.id)
  def filter(query, :preload, preloads), do: preload(query, ^preloads)
  def filter(query, :order, :oldest), do: order_by(query, [v], asc: v.id)
  def filter(query, :order, :newest), do: order_by(query, [v], desc: v.id)

  def filter(query, :project, proj) do
    from v in query,
      join: pm in assoc(v, :prompt),
      join: pj in assoc(pm, :project),
      where: pj.id == ^proj.id
  end

  def filter(query, :coded, true) do
    where(query, [v], fragment("EXISTS (SELECT * FROM codings WHERE video_id = ?)", v.id))
  end

  def filter(query, :coded, false) do
    where(query, [v], fragment("NOT EXISTS (SELECT * FROM codings WHERE video_id = ?)", v.id))
  end

  def filter(query, :order, :last_coded) do
    from v in query,
      left_join: c in assoc(v, :coding),
      order_by: [
        asc: fragment("? IS NULL", c.id),
        desc: c.inserted_at,
        asc: v.inserted_at
      ]
  end

  def filter(orig_query, :having_tags, tag_maps) do
    tag_names = Enum.map(tag_maps, & &1.text)

    Enum.reduce(tag_names, orig_query, fn tag_name, query ->
      where(query, [v], fragment("EXISTS (
        SELECT * FROM codings c
          JOIN taggings ti ON c.id = ti.coding_id
          JOIN tags t ON ti.tag_id = t.id
        WHERE c.video_id = ? AND t.text = ?)", v.id, ^tag_name))
    end)
  end
end
