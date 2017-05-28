defmodule Zb.Interview do
  use Zb.Web, :model
  alias Zb.Repo

  schema "interviews" do
    belongs_to :user, Zb.User # indexed
    belongs_to :question, Zb.Question # indexed
    field :completed_at, Timex.Ecto.DateTime # UTC
    field :recording, :string # Arc attachment filename
    has_many :votes, Zb.Vote
    timestamps()
  end

  def admin_changeset(struct, params \\ %{}) do
    struct
      |> cast(params, [:user_id, :question_id])
      |> validate_required([:user_id, :question_id])
      |> assoc_constraint(:user)
      |> assoc_constraint(:question)
  end

  def interviewee_changeset(struct, params \\ %{}) do
    struct
      |> cast(params, [:recording])
      |> validate_required([:recording])
      |> put_change(:completed_at, Timex.now)
  end

  # Query helpers

  def completed(query) do
    query |> where([i], not is_nil(i.completed_at))
  end

  def incomplete(query) do
    query |> where([i], is_nil(i.completed_at))
  end

  def by(query, user) do
    query |> where([i], i.user_id == ^user.id)
  end

  def not_by(query, user) do
    query |> where([i], i.user_id != ^user.id)
  end

  def not_voted_on_by(query, user) do
    query |> where(fragment("id NOT IN (SELECT interview_id FROM votes WHERE user_id = ?)", ^user.id))
  end

  def eligible_for_voting(query) do
    question = Zb.Question |> where([q], q.eligible_for_voting == true) |> Repo.first
      || raise("No question is eligible_for_voting!")
    query |> where([i], i.question_id == ^question.id)
  end
end
