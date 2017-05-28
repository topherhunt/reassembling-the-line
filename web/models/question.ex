defmodule Zb.Question do
  use Zb.Web, :model

  alias Zb.{Repo, Question}

  schema "questions" do
    field :position, :integer
    field :text, :string
    field :eligible_for_voting, :boolean
    has_many :interviews, Zb.Interview
    timestamps()
  end

  # No changeset needed for now. Questions are always defined from the command line.

  def voting_target do
    Question |> Repo.get_by!(eligible_for_voting: true) # asserts only 1 match
  end
end
