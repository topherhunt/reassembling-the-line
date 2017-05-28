defmodule Zb.Vote do
  use Zb.Web, :model

  alias Zb.Tag

  schema "votes" do
    belongs_to :user, Zb.User # indexed - this is the voter, not the interviewee
    belongs_to :interview, Zb.Interview # indexed
    field :vote_agreement, :integer
    field :vote_influenced, :integer
    field :tag_list, :string, virtual: true
    timestamps()
    has_many :vote_taggings, Zb.VoteTagging
    has_many :tags, through: [:vote_taggings, :tag]
  end

  def voter_changeset(struct, params \\ %{}) do
    # user_id and interview_id are set in the controller, not user-editable params
    struct
      |> cast(params, [:vote_agreement, :vote_influenced, :tag_list])
      |> validate_required([:user_id, :interview_id, :vote_agreement, :vote_influenced, :tag_list])
      |> validate_inclusion(:vote_agreement, 1..4)
      |> validate_inclusion(:vote_influenced, 1..4)
      |> assoc_constraint(:user)
      |> assoc_constraint(:interview)
      |> validate_and_persist_tags
  end

  defp validate_and_persist_tags(changeset) do
    tags = valid_tag_changesets(changeset)
    if length(tags) in 1..2 do
      changeset # |> put_assoc(:tags, persist_tags(tags))
    else
      changeset |> add_error(:tag_list, "Please select between one and two tags.")
    end
  end

  defp valid_tag_changesets(vote_changeset) do
    (get_change(vote_changeset, :tag_list) || vote_changeset.data.tag_list || "")
      |> String.split(",")
      |> Enum.map(fn(text) ->
        text = String.trim(text)
        Tag.voter_changeset(%Tag{}, %{text: text}) end)
      |> Enum.filter(fn(tag_changeset) ->
        tag_changeset.valid? end)
  end

  # defp persist_tags(tag_changesets) do
  #   tag_changesets |> Enum.map(fn(changeset) ->
  #     Repo.insert(changeset) # Failure due to unique index race conditions is OK
  #   end)
  # end
end
