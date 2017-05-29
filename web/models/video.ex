defmodule EducateYour.Video do
  use EducateYour.Web, :model

  schema "videos" do
    field :title, :string
    field :source_name, :string
    field :source_url, :string
    field :recording_url, :string
    field :preview_image_url, :string
    timestamps()
    has_one :coding, EducateYour.Coding
  end

  # === Changesets ===

  def changeset(struct, params \\ %{}) do
    struct
      |> cast(params, [:title, :source_name, :source_url, :recording_url, :preview_image_url])
      |> validate_required([:title, :recording_url])
  end
end
