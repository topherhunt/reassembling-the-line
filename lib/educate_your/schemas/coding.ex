defmodule EducateYour.Schemas.Coding do
  use Ecto.Schema
  import Ecto.Changeset
  import EducateYour.Helpers
  alias EducateYour.Repo
  alias EducateYour.Schemas.{Tagging, Tag, User, Video}

  schema "codings" do
    belongs_to :video, Video
    belongs_to :updated_by_user, User
    timestamps()

    has_many :taggings, Tagging
    has_many :tags, through: [:taggings, :tag]
  end

  ##
  # Changesets
  #

  def create_changeset(struct, params \\ %{}) do
    struct
      |> cast(params, [:video_id, :updated_by_user_id])
      |> validate_required([:video_id, :updated_by_user_id])
      |> unique_constraint(:video_id)
  end

  def update_changeset(struct, params \\ %{}) do
    struct
      |> cast(params, [:updated_by_user_id])
      |> validate_required([:updated_by_user_id])
  end

  ##
  # Helpers
  #

  def associate_tags(coding, tags_list) do
    tags_list
      |> Enum.reject(fn(params)-> is_blank?(params["text"]) end)
      |> Enum.each(fn(params) ->
        tag = Tag.find_or_create(params)
        tagging_changeset = Tagging.changeset(%Tagging{}, %{
          coding_id: coding.id,
          tag_id: tag.id,
          starts_at: time_to_integer(params["starts_at"]),
          ends_at:   time_to_integer(params["ends_at"])
        })
        Repo.insert!(tagging_changeset)
      end)
  end

  def compact_tag_info(coding) do
    # assumes %{taggings: :tag} is already preloaded
    coding.taggings |> Enum.map(fn(tagging)->
      %{
        text: tagging.tag.text,
        starts_at: integer_to_time(tagging.starts_at),
        ends_at:   integer_to_time(tagging.ends_at)
      }
    end)
  end
end
