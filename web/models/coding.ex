defmodule EducateYour.Coding do
  use EducateYour.Web, :model
  alias EducateYour.{Repo, Tagging, Tag}

  schema "codings" do
    belongs_to :video, EducateYour.Video
    belongs_to :updated_by_user, EducateYour.User
    timestamps()
    has_many :taggings, EducateYour.Tagging
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
    Enum.each(tags_list, fn(tag_map) ->
      tag = Tag.find_or_create(tag_map)
      tagging_changeset = Tagging.changeset(%Tagging{}, %{
        coding_id: coding.id,
        tag_id: tag.id,
        starts_at: tag_map["starts_at"],
        ends_at: tag_map["ends_at"]
      })
      Repo.insert!(tagging_changeset)
    end)
  end

  def compact_tag_info(coding) do
    # assumes %{taggings: :tag} is already preloaded
    coding.taggings |> Enum.map(fn(tagging)->
      %{
        context: tagging.tag.context,
        text: tagging.tag.text,
        starts_at: tagging.starts_at,
        ends_at: tagging.ends_at
      }
    end)
  end
end
