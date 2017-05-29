defmodule EducateYour.Tagging do
  use EducateYour.Web, :model

  schema "taggings" do
    belongs_to :video, EducateYour.Video
    belongs_to :coding, EducateYour.Coding
    belongs_to :tag, EducateYour.Tag
    timestamps()
  end

  # === Changesets ===

  def changeset(struct, params \\ %{}) do
    struct
      |> cast(params, [:video_id, :coding_id, :tag_id])
      |> validate_required([:video_id, :coding_id, :tag_id])
  end
end
