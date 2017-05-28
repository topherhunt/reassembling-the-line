defmodule Zb.VoteView do
  use Zb.Web, :view

  import Ecto

  alias Zb.{Repo, Interview}

  def voting_progress_data(user) do
    completed = user |> assoc(:votes) |> Repo.count
    total = Interview
      |> Interview.completed
      |> Interview.not_by(user)
      |> Interview.eligible_for_voting
      |> Repo.count
    min_to_do = [(user.min_votes_needed - completed), (total - completed)] |> Enum.min
    %{ completed: completed, total: total, min_to_do: min_to_do }
  end
end
