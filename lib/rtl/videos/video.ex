defmodule RTL.Videos.Video do
  use Ecto.Schema
  import Ecto.Changeset
  require Ecto.Query
  alias Ecto.Query, as: Q
  alias RTL.Repo

  schema "videos" do
    belongs_to :prompt, RTL.Projects.Prompt
    # Only populated if the source video has a title, e.g. Youtube
    # (The primary-use-case story recordings won't have a title.)
    field :title, :string
    # required if this is a webcam recording (to protect submitter's right to deletion)
    field :speaker_name, :string
    # eg. the original Youtube url if relevant
    field :source_url, :string
    # Permission values: "researchers", "public". May be null.
    field :permission, :string
    # whether the speaker_name (which is required) may be shown to researchers & viewers
    field :permission_show_name, :boolean
    field :recording_filename, :string
    field :thumbnail_filename, :string
    timestamps()

    has_one :coding, RTL.Videos.Coding
    has_many :taggings, through: [:coding, :taggings]
    has_many :tags, through: [:coding, :tags]
  end

  #
  # Public API (very WIP)
  #

  def get!(id, f \\ []), do: __MODULE__ |> apply_filters([{:id, id} | f]) |> Repo.one!()
  def first(filters \\ []), do: __MODULE__ |> apply_filters(filters) |> Repo.first()
  def all(filters \\ []), do: __MODULE__ |> apply_filters(filters) |> Repo.all()
  def count(filters \\ []), do: __MODULE__ |> apply_filters(filters) |> Repo.count()

  # TODO: Maybe the generic mostly-universal api lives in the schema, whereas the more specific services (such as "validate and insert a webcam recording") live on the context?
  def insert_webcam_recording!(params) do
    new_webcam_recording_changeset(params) |> Repo.insert!()
  end

  def generic_changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [
      :prompt_id,
      :title,
      :speaker_name,
      :source_url,
      :permission,
      :permission_show_name,
      :recording_filename,
      :thumbnail_filename
    ])
    |> validate_required([
      :prompt_id,
      :recording_filename,
      :thumbnail_filename
    ])
  end

  def new_webcam_recording_changeset(params \\ %{}) do
    webcam_recording_changeset(%RTL.Videos.Video{}, params)
  end

  def webcam_recording_changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [
      :prompt_id,
      :speaker_name,
      :permission,
      :permission_show_name,
      :recording_filename,
      :thumbnail_filename
    ])
    |> validate_required([
      :prompt_id,
      :speaker_name,
      :permission,
      :permission_show_name,
      :recording_filename,
      :thumbnail_filename
    ])
  end

  #
  # Filters
  #

  def apply_filters(starting_query, filters) do
    Enum.reduce(filters, starting_query, fn {k, v}, query -> filter(query, k, v) end)
  end

  def filter(query, :id, id), do: Q.where(query, [v], v.id == ^id)
  def filter(query, :source_url, url), do: Q.where(query, [v], v.source_url == ^url)
  def filter(query, :prompt, prompt), do: Q.where(query, [v], v.prompt_id == ^prompt.id)
  def filter(query, :preload, preloads), do: Q.preload(query, ^preloads)
  def filter(query, :order, :oldest), do: Q.order_by(query, [v], asc: v.id)
  def filter(query, :order, :newest), do: Q.order_by(query, [v], desc: v.id)

  def filter(query, :project, proj) do
    Q.from v in query,
      join: pm in assoc(v, :prompt),
      join: pj in assoc(pm, :project),
      where: pj.id == ^proj.id
  end

  def filter(query, :coded, true) do
    Q.where(query, [v], fragment("EXISTS (SELECT * FROM codings WHERE video_id = ? AND completed_at IS NOT NULL)", v.id))
  end

  # NOTE: For the "Tag the next video" feature, we're directing you to the first video
  # where coding hasn't been completed. This won't work well if there are multiple coders
  # on a project.
  def filter(query, :coded, false) do
    Q.where(query, [v], fragment("NOT EXISTS (SELECT * FROM codings WHERE video_id = ? AND completed_at IS NOT NULL)", v.id))
  end

  def filter(query, :order, :last_coded) do
    Q.from v in query,
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
      Q.where(query, [v], fragment("EXISTS (
        SELECT * FROM codings c
          JOIN taggings ti ON c.id = ti.coding_id
          JOIN tags t ON ti.tag_id = t.id
        WHERE c.video_id = ? AND t.text = ?)", v.id, ^tag_name))
    end)
  end
end
