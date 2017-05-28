defmodule AdminInterfaceTest do
  use Zb.IntegrationCase

  hound_session()

  test "non-admin user is blocked from viewing the page", %{conn: conn} do
    insert :user, type: "admin"
    other_user = insert :user, type: "faculty"
    navigate_to session_path(conn, :login_from_uuid, other_user.uuid)
    navigate_to admin_user_path(conn, :index)
    assert current_path() == "/"
    assert visible_page_text() =~ "You must be an admin to access that page."
  end

  test "admin lands on the admin landing page", %{conn: conn} do
    admin = insert :user, type: "admin"
    navigate_to session_path(conn, :login_from_uuid, admin.uuid)
    assert current_path() == "/admin"
    assert visible_page_text() =~ "Admin dashboard"
  end

  test "admin can list Users", %{conn: conn} do
    admin = insert :user, type: "admin"
    u1 = insert :user
    u2 = insert :user
    u3 = insert :user

    navigate_to session_path(conn, :login_from_uuid, admin.uuid)
    navigate_to admin_user_path(conn, :index)
    [u1, u2, u3] |> Enum.each(fn(user) ->
      assert visible_page_text() =~ user.full_name
      assert page_source() =~ admin_user_path(conn, :show, user)
    end)
    assert_selector(:css, ".filter-users")
  end

  test "admin can view User details", %{conn: conn} do
    # Dummy data
    user = insert :user, min_votes_needed: 20
    q1 = insert :question, position: 1
    i1 = insert :interview, user: user, question: q1, completed_at: Timex.now
    v1 = insert :vote, interview: i1 # Someone else rated my interview
    t1 = insert :tag
    insert :vote_tagging, vote: v1, tag: t1
    insert :vote, user: user # I've rated another interview
    insert :scheduled_task, user: user

    admin = insert :user, type: "admin"
    navigate_to session_path(conn, :login_from_uuid, admin.uuid)
    navigate_to admin_user_path(conn, :show, user)
    assert "Details on user: #{user.full_name}"
    assert_selector(:css, ".basic-info")
    assert_selector(:css, ".my-scheduled-tasks")
    assert_selector(:css, ".my-interviews")
    assert_selector(:css, ".my-votes")
  end

  # PENDING: test "admin can batch uploads Users from .csv", %{conn: conn} do
  #   admin = insert :user, type: "admin"
  #   navigate_to session_path(conn, :login_from_uuid, admin.uuid)
  #   navigate_to admin_user_path(conn, :batch_new)
  #   assert visible_page_text() =~ "Import users from .csv"
  #   # The rest is covered in controller tests.
  #   raise "TODO: Move the following tests to controller tests:"
  #   # - Successful import
  #   assert Repo.count(User) == 1
  #   find_element(:css, ".csv-field") |> fill_field("path/to/file.csv")
  #   find_element(:css, ".upload-submit-button") |> click
  #   assert current_path() == "/admin"
  #   assert visible_page_text() =~ "Successfully imported 10 users (10 faculty members). You'll need to create these users' Interviews and ScheduledTasks yourself."
  #   assert Repo.count(User) == 11
  #   # - Import fails if any validation errors exist
  #   admin = insert :user, type: "admin"
  #   admin = insert :user, email: "user1@example.com"
  #   navigate_to session_path(conn, :login_from_uuid, admin.uuid)
  #   navigate_to admin_user_path(conn, :batch_new)
  #   assert Repo.count(User) == 2
  #   find_element(:css, ".csv-field") |> fill_field("path/to/file.csv")
  #   find_element(:css, ".upload-submit-button") |> click
  #   assert current_path() == admin_user_path(conn, :batch_new)
  #   assert visible_page_text() =~ "Upload failed due to the following errors. No changes were made."
  #   assert Repo.count(User) == 2
  # end

  test "admin can list Questions", %{conn: conn} do
    # Dummy data
    q1 = insert :question
    q2 = insert :question
    q3 = insert :question
    insert :interview, question: q1, completed_at: nil
    insert :interview, question: q2, completed_at: Timex.now

    admin = insert :user, type: "admin"
    navigate_to session_path(conn, :login_from_uuid, admin.uuid)
    navigate_to admin_question_path(conn, :index)
    assert visible_page_text() =~ q1.text
    assert visible_page_text() =~ q2.text
    assert visible_page_text() =~ q3.text
    # PENDING: assert_selector(:css, "a.link-to-interviews", count: 3)
  end

  test "admin can list Interviews", %{conn: conn} do
    # Set up some medium-complex data
    i1 = insert :interview
    i2 = insert :interview
    i3 = insert :interview

    admin = insert :user, type: "admin"
    navigate_to session_path(conn, :login_from_uuid, admin.uuid)
    navigate_to admin_interview_path(conn, :index)
    assert visible_page_text() =~ i1.user.full_name
    assert visible_page_text() =~ i2.user.full_name
    assert visible_page_text() =~ i3.user.full_name
    assert_selector(:css, ".filter-interviews")
  end

  test "admin can view Interview details", %{conn: conn} do
    interview = insert :interview

    admin = insert :user, type: "admin"
    navigate_to session_path(conn, :login_from_uuid, admin.uuid)
    navigate_to admin_interview_path(conn, :show, interview)
    assert visible_page_text() =~ "Details on interview ##{interview.id}"
    assert_selector(:css, ".basic-info")
    assert_selector(:css, ".play-video")
    assert_selector(:css, ".votes-list")
  end

  test "admin can list Tags", %{conn: conn} do
    # Dummy data
    t1 = insert :tag, recommended: true
    t2 = insert :tag, recommended: true
    t3 = insert :tag
    v1 = insert :vote
    insert :vote_tagging, vote: v1, tag: t1

    admin = insert :user, type: "admin"
    navigate_to session_path(conn, :login_from_uuid, admin.uuid)
    navigate_to admin_tag_path(conn, :index)
    assert visible_page_text() =~ t1.text
    assert visible_page_text() =~ t2.text
    assert visible_page_text() =~ t3.text
    # PENDING: assert_selector(:css, ".link-to-interviews", count: 3)
  end

  test "admin can list ScheduledTasks", %{conn: conn} do
    # Dummy data
    # TODO: This intricate setup makes a really good argument for ScheduledTask
    # having a foreign key to point to its interview, instead of just an encoded
    # question number. Consider how hard that change would be.
    q1 = insert :question, position: 1
    q2 = insert :question, position: 2
    q3 = insert :question, position: 3
    u1 = insert :user
    insert :interview, user: u1, question: q1
    insert :interview, user: u1, question: q2
    insert :interview, user: u1, question: q3
    t1 = insert :scheduled_task, user: u1, command: "do_interview:1"
    t2 = insert :scheduled_task, user: u1, command: "do_interview:2"
    t3 = insert :scheduled_task, user: u1, command: "do_interview:3"
    t4 = insert :scheduled_task, user: u1, command: "meet_voting_quota"

    admin = insert :user, type: "admin"
    navigate_to session_path(conn, :login_from_uuid, admin.uuid)
    navigate_to admin_scheduled_task_path(conn, :index)
    assert visible_page_text() =~ t1.user.full_name
    assert visible_page_text() =~ t2.user.full_name
    assert visible_page_text() =~ t3.user.full_name
    assert visible_page_text() =~ t4.user.full_name
    assert_selector(:css, ".link-to-user", count: 4)
    assert_selector(:css, ".filter-scheduled-tasks")
  end

  test "admin can list and view ContactRequests", %{conn: conn} do
    admin = insert :user, type: "admin"
    insert :contact_request
    insert :contact_request
    insert :contact_request

    navigate_to session_path(conn, :login_from_uuid, admin.uuid)
    navigate_to admin_contact_request_path(conn, :index)
    assert_selector(:css, ".contact-request-row", count: 3)
    find_all_elements(:css, ".link-to-request") |> List.first |> click
    assert visible_page_text() =~ "Details on contact request"
  end
end
