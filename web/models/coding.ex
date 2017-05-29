defmodule EducateYour.Coding do
  use EducateYour.Web, :model

  schema "codings" do
    belongs_to :video, EducateYour.Video
    belongs_to :updated_by_user, EducateYour.User
    timestamps()
    has_many :taggings, EducateYour.Tagging
  end

  # === Changesets ===

  def changeset(struct, params \\ %{}) do
    struct
      |> cast(params, [:video_id, :updated_by_user_id])
      |> validate_required([:video_id, :updated_by_user_id])
      |> unique_constraint(:video_id)
  end
end
