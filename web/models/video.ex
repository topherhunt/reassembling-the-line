defmodule EducateYour.Video do
  use EducateYour.Web, :model
  alias EducateYour.GenericAttachment

  schema "videos" do
    field :title, :string
    field :source_name, :string
    field :source_url, :string
    field :recording_filename, :string
    field :thumbnail_filename, :string
    timestamps()
    has_one :coding, EducateYour.Coding
  end

  ##
  # Changesets
  #

  def changeset(struct, params \\ %{}) do
    struct
      |> cast(params, [:title, :source_name, :source_url, :recording_filename, :thumbnail_filename])
      |> validate_required([:title, :recording_filename, :thumbnail_filename])
  end

  ##
  # Helpers
  #

  def recording_url(video) do
    GenericAttachment.url({video.recording_filename, "recording"})
  end

  def thumbnail_url(video) do
    GenericAttachment.url({video.thumbnail_filename, "thumbnail"})
  end
end
