defmodule Zb.VoteControllerTest do
  use Zb.ConnCase, async: true

  test "all actions require logged-in user", %{conn: conn} do
    [
      get(conn, vote_path(conn, :select_random)),
      get(conn, interview_vote_path(conn, :new, "123")),
      post(conn, interview_vote_path(conn, :create, "123"))
    ] |> Enum.each(fn(conn) ->
      assert redirected_to(conn) == session_path(conn, :new)
      assert conn.halted
    end)
  end

  test "#new and #create require a valid interview", %{conn: conn} do
    {conn, _} = login_as_new_user(conn)

    assert_error_sent 404, fn ->
      get(conn, interview_vote_path(conn, :new, "123")) end
    assert_error_sent 404, fn ->
      post(conn, interview_vote_path(conn, :create, "123", vote: %{a: :b})) end
  end

  test "#select_random redirects to a random eligible interview", %{conn: conn} do
    question = insert :question, eligible_for_voting: true
    {conn, user} = login_as_new_user(conn)
    # Set up 5 test interviews, only 2 of which are eligible for voting by me
    interview1 = add_interview(question: question, completed_at: nil)
    interview2 = add_interview(question: question, completed_at: Timex.now, user: user)
    interview3 = add_interview(question: question, completed_at: Timex.now)
    insert :vote, user: user, interview: interview3
    interview4 = add_interview(question: question, completed_at: Timex.now)
    interview5 = add_interview(question: question, completed_at: Timex.now)
    # Request a random interview 100 times
    result_urls = (1..100) |> Enum.map(fn(_) ->
      get(conn, vote_path(conn, :select_random)) |> redirected_to
    end)
    # Verify that I'm only redirected to the eligible interviews
    assert never_points_to?(result_urls, interview1) # the interview is incomplete
    assert never_points_to?(result_urls, interview2) # I submitted this interview
    assert never_points_to?(result_urls, interview3) # I've already voted on this
    assert sometimes_points_to?(result_urls, interview4) # valid
    assert sometimes_points_to?(result_urls, interview5) # valid
  end

  test "#select_random redirects to #done if no votable interviews", %{conn: conn} do
    insert :question, eligible_for_voting: true # prevent sanity check errors
    {conn, _} = login_as_new_user(conn)
    add_interview(completed_at: nil)
    # Interviews exist, but I can't vote on any, so I'm redirected to done.
    conn = get(conn, vote_path(conn, :select_random))
    assert redirected_to(conn) == vote_path(conn, :done)
  end

  test "#new renders", %{conn: conn} do
    {conn, _} = login_as_new_user(conn)
    question = insert :question, eligible_for_voting: true
    interview = add_interview(completed_at: Timex.now, question: question)
    conn = get(conn, interview_vote_path(conn, :new, interview.id))
    assert html_response(conn, 200) =~ "Categorize a Submission"
  end

  test "#create records the vote & tags and redirects if valid", %{conn: conn} do
    {conn, user}  = login_as_new_user(conn, %{min_votes_needed: 3})
    (1..4) |> Enum.each(fn(_) -> add_interview(completed_at: Timex.now) end)
    interview = add_interview(completed_at: Timex.now)
    insert :tag, text: "one"

    conn = post(conn, interview_vote_path(conn, :create, interview.id), vote:
      %{ vote_agreement: 3, vote_influenced: 1, tag_list: "One,TWO" })
    assert redirected_to(conn) == vote_path(conn, :select_random)
    assert get_flash(conn, :info) == "Thanks! Your ratings have been saved."
    assert Repo.count(Zb.Vote) == 1
    assert Repo.count(Zb.Tag) == 2 # despite capitalization differences
    vote = Repo.first(Zb.Vote)
    assert vote.user_id == user.id
    assert vote.interview_id == interview.id
    assert vote.vote_agreement == 3
    assert vote.vote_influenced == 1
    assert vote |> tags_text |> Enum.sort == ["one", "two"]
  end

  test "#create makes no changes and shows errors if invalid", %{conn: conn} do
    {conn, _}  = login_as_new_user(conn)
    interview = insert :interview, completed_at: Timex.now

    conn = post(conn, interview_vote_path(conn, :create, interview.id), vote: %{})
    assert html_response(conn, 200) =~ "See error messages below."
    assert Repo.count(Zb.Vote) == 0
    assert Repo.count(Zb.Tag) == 0
  end

  # Helpers

  defp add_interview(opts) do
    insert :interview, opts
  end

  defp sometimes_points_to?(list, interview) do
    Enum.find(list, fn(url) ->
      url == "/interviews/#{interview.id}/votes/new"
    end) != nil
  end

  defp never_points_to?(list, interview) do
    ! sometimes_points_to?(list, interview)
  end

  defp tags_text(vote) do
    vote |> assoc(:tags) |> Repo.all |> Enum.map(fn(t) -> t.text end)
  end
end
