defmodule EducateYour.Videos.Coding do
  use Ecto.Schema
  import Ecto.Changeset

  schema "codings" do
    belongs_to :video, EducateYour.Videos.Video
    belongs_to :updated_by_user, EducateYour.Accounts.User
    timestamps()

    has_many :taggings, EducateYour.Videos.Tagging
    has_many :tags, through: [:taggings, :tag]
  end

  def changeset(struct, params \\ %{}) do
    struct
      |> cast(params, [:video_id, :updated_by_user_id])
      |> validate_required([:video_id, :updated_by_user_id])
      |> unique_constraint(:video_id)
  end
end
