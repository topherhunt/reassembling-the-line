defmodule RTL.Videos.Coding do
  use Ecto.Schema
  import Ecto.Changeset

  schema "codings" do
    belongs_to :video, RTL.Videos.Video
    belongs_to :updated_by_user, RTL.Accounts.User
    timestamps()

    has_many(:taggings, RTL.Videos.Tagging)
    has_many(:tags, through: [:taggings, :tag])
  end

  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:video_id, :updated_by_user_id])
    |> validate_required([:video_id, :updated_by_user_id])
    |> unique_constraint(:video_id)
  end
end
