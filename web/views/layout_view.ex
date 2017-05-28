defmodule Zb.LayoutView do
  use Zb.Web, :view

  def next_action_link_for(conn, user, classes \\ "") do
    # Note that this displays the link regardless of whether the task is DUE or not.
    case Zb.TaskComputer.next_available_action(user) do
      {:do_interview, interview} ->
        link "Question #{interview.question.position}", to: interview_path(conn, :edit, interview), class: "record-interview-link #{classes}"
      {:vote} ->
        link "Rate responses", to: vote_path(conn, :select_random), class: "vote-link #{classes}"
      {:nothing} ->
        # Continue showing the vote link even if the user has met their quota.
        link "Rate responses", to: vote_path(conn, :select_random), class: "vote-link #{classes}"
    end
  end
end
