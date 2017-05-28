defmodule Zb.InterviewControllerTest do
  use Zb.ConnCase, async: true

  test "all actions require logged-in user", %{conn: conn} do
    [
      get(conn, interview_path(conn, :edit, "123")),
      patch(conn, interview_path(conn, :update, "123")),
      get(conn, interview_path(conn, :done))
    ] |> Enum.each(fn(conn) ->
      assert redirected_to(conn) == session_path(conn, :new)
    end)
  end

  test "#edit and #update render 404 if interview isn't mine, is complete, or doesn't exist", %{conn: conn} do
    {conn, user} = login_as_new_user(conn)
    i1 = insert :interview
    i2 = insert :interview, user: user, completed_at: Timex.now

    assert_error_sent 404, fn ->
      get(conn, interview_path(conn, :edit, i1.id)) end # not by me
    assert_error_sent 404, fn ->
      get(conn, interview_path(conn, :edit, i2.id)) end # already complete
    assert_error_sent 404, fn ->
      get(conn, interview_path(conn, :edit, "123")) end # doesn't exist
    assert_error_sent 404, fn ->
      patch(conn, interview_path(conn, :update, "123", interview: %{a: :b})) end
  end

  test "#edit renders", %{conn: conn} do
    {conn, user} = login_as_new_user(conn)
    interview = insert :interview, user: user

    conn = get(conn, interview_path(conn, :edit, interview.id))
    assert html_response(conn, 200) =~ "Record your response"
  end

  test "#update updates the record and redirects", %{conn: conn} do
    {conn, user} = login_as_new_user(conn)
    interview = insert :interview, user: user

    conn = patch(conn, interview_path(conn, :update, interview.id), interview: %{recording: "something.mp4"})
    assert redirected_to(conn) == interview_path(conn, :done)
    assert interview.recording == nil
    assert interview.completed_at == nil
    interview = Repo.get!(Zb.Interview, interview.id)
    assert interview.recording == "something.mp4"
    assert interview.completed_at != nil
  end

  test "#update raises an error if invalid params are supplied", %{conn: conn} do
    {conn, user} = login_as_new_user(conn)
    interview = insert :interview, user: user

    # If the interface and JS are working, the user can't submit invalid params.
    assert_raise Ecto.InvalidChangesetError, fn ->
      patch(conn, interview_path(conn, :update, interview.id), interview: %{recording: ""}) end
  end

  test "#done renders when an interview is due", %{conn: conn} do
    {conn, user} = login_as_new_user(conn)
    question = insert :question, position: 5
    insert :interview, user: user, question: question
    insert :scheduled_task, user: user, command: "do_interview:5", due_on_date: yesterday()

    conn = get(conn, interview_path(conn, :done))
    assert html_response(conn, 200) =~ "Thank you for taking the time to do that interview! Now it's time to respond to question #5."
  end

  test "#done renders when voting is due", %{conn: conn} do
    {conn, user} = login_as_new_user(conn, min_votes_needed: 5)
    insert :scheduled_task, user: user, command: "meet_voting_quota", due_on_date: yesterday()

    conn = get(conn, interview_path(conn, :done))
    assert html_response(conn, 200) =~ "Thank you for taking the time to do that interview! Now it's time to watch and categorize others' responses."
  end

  test "#done renders when nothing is due, but an interview is available", %{conn: conn} do
    {conn, user} = login_as_new_user(conn)
    question = insert :question, position: 5
    insert :interview, user: user, question: question
    insert :scheduled_task, user: user, command: "do_interview:5", due_on_date: tomorrow()

    conn = get(conn, interview_path(conn, :done))
    assert html_response(conn, 200) =~ "Thank you for taking the time to do that interview! We've received your response; that's all we needed from you today."
    assert conn.resp_body =~ "If you have the time, you may continue to the next question now by clicking the button below."
  end

  test "#done renders when nothing is due, but voting is available", %{conn: conn} do
    {conn, user} = login_as_new_user(conn, min_votes_needed: 5)
    insert :scheduled_task, user: user, command: "meet_voting_quota", due_on_date: tomorrow()

    conn = get(conn, interview_path(conn, :done))
    assert html_response(conn, 200) =~ "Thank you for taking the time to do that interview! We've received your response; that's all we needed from you today."
    assert conn.resp_body =~ "If you have the time, you may continue to the next phase now by clicking the <strong>Rate Responses</strong> button below."
  end

  test "#done renders when nothing is due and all tasks are complete", %{conn: conn} do
    {conn, user} = login_as_new_user(conn, min_votes_needed: 0)
    insert :scheduled_task, user: user, command: "meet_voting_quota", due_on_date: tomorrow()

    conn = get(conn, interview_path(conn, :done))
    assert html_response(conn, 200) =~ "Thank you for taking the time to do that interview! We've received your response; that's all we needed from you today."
    refute conn.resp_body =~ "If you have the time"
  end

  # Helpers

  defp yesterday do
    Timex.today |> Timex.shift(days: -1)
  end

  defp tomorrow do
    Timex.today |> Timex.shift(days: 1)
  end
end
