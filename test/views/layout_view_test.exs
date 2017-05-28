defmodule Zb.LayoutViewTest do
  use Zb.ConnCase, async: true

  alias Zb.LayoutView

  test "#next_action_link_for links to my pending interview if any", %{conn: conn} do
    user = insert :user, min_votes_needed: 1
    question = insert :question, position: 1
    interview = insert :interview, user: user, question: question, completed_at: nil
    insert :scheduled_task, user: user, command: "do_interview:1"

    output = LayoutView.next_action_link_for(conn, user) |> Phoenix.HTML.safe_to_string
    assert output =~ "record-interview-link"
    assert output =~ interview_path(conn, :edit, interview)
  end

  test "#next_action_link_for links to the vote path if I have no pending interviews", %{conn: conn} do
    user = insert :user

    output = LayoutView.next_action_link_for(conn, user) |> Phoenix.HTML.safe_to_string
    assert output =~ "vote-link"
    assert output =~ vote_path(conn, :select_random)
  end
end
