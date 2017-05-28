defmodule Zb.SessionControllerTest do
  use Zb.ConnCase, async: true

  defp assert_logged_in(conn, user) do
    conn = get(conn, "/") # make another request
    assert get_session(conn, :user_id) == user.id
  end

  defp assert_not_logged_in(conn) do
    conn = get(conn, "/") # make another request
    assert get_session(conn, :user_id) == nil
  end

  @valid_attrs   %{email: "a@b.c", password: "password"}
  @invalid_attrs %{email: "a@b.c", password: "password2"}

  test "#new displays the login form", %{conn: conn} do
    conn = get(conn, session_path(conn, :new))
    assert html_response(conn, 200) =~ "Log in"
  end

  test "#create logs me in if credentials match", %{conn: conn} do
    user = insert :user, email: "a@b.c"
    assert_not_logged_in(conn)
    conn = post(conn, session_path(conn, :create), session: @valid_attrs)
    assert redirected_to(conn) == "/"
    assert_logged_in(conn, user)
  end

  test "#create doesn't log me in if credentials don't match", %{conn: conn} do
    insert :user, email: "a@b.c"
    conn = post(conn, session_path(conn, :create), session: @invalid_attrs)
    assert html_response(conn, 200) =~ "That email or password is incorrect."
    assert_not_logged_in(conn)
  end

  test "#login_from_uuid logs me in and redirects if uuid matches", %{conn: conn} do
    user = insert :user
    conn = get(conn, session_path(conn, :login_from_uuid, user.uuid), redirect_to: interview_path(conn, :edit, "123"))
    assert get_session(conn, :user_id) == user.id
    assert redirected_to(conn) == interview_path(conn, :edit, "123")
  end

  test "#login_from_uuid default redirects to my pending interview", %{conn: conn} do
    question = insert :question, position: 1
    user = insert :user, min_votes_needed: 1
    interview = insert :interview, user: user, question: question, completed_at: nil
    insert :scheduled_task, user: user, command: "do_interview:1"
    conn = get(conn, session_path(conn, :login_from_uuid, user.uuid))
    assert redirected_to(conn) == interview_path(conn, :edit, interview)
  end

  test "#login_from_uuid defaults to /interviews/done if no tasks left", %{conn: conn} do
    user = insert :user
    insert :scheduled_task, user: user, command: "meet_voting_quota"
    conn = get(conn, session_path(conn, :login_from_uuid, user.uuid))
    assert redirected_to(conn) == interview_path(conn, :done)
    # /vote/select_random redirects to /vote/done if nothing is available for voting
  end

  test "#login_from_uuid raises 404 if uuid doesn't match", %{conn: conn} do
    user = insert :user
    assert_error_sent 404, fn ->
      get(conn, session_path(conn, :login_from_uuid, user.uuid <> "9"), redirect_to: interview_path(conn, :edit, "123")) end
  end

  test "#delete logs me out", %{conn: conn} do
    user = insert :user, email: "a@b.c"
    conn = post(conn, session_path(conn, :create), session: @valid_attrs)
    assert_logged_in(conn, user)
    conn = delete(conn, session_path(conn, :delete, "blah"))
    assert_not_logged_in(conn)
  end
end
