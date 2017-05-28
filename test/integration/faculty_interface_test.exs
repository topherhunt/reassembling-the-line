defmodule FacultyInterfaceTest do
  use Zb.IntegrationCase
  alias Zb.{Interview, Vote, ContactRequest}

  hound_session()

  test "faculty can record an interview", %{conn: conn} do
    question  = insert :question, position: 1
    user      = insert :user, type: "faculty"
    interview = insert :interview, user: user, question: question, completed_at: nil
    insert :scheduled_task, user: user, command: "do_interview:1"

    # Log in via the generic autologin URL; auto redirected to my incomplete interview
    navigate_to session_path(conn, :login_from_uuid, user.uuid)
    assert current_path() == interview_path(conn, :edit, interview)
    assert_selector(:css, "#recording-video")
    # Skip the video recording and AJAX S3 upload, and just submit the hidden form
    execute_script(" $('.js-recording-submit-container').show(); ")
    find_element(:css, ".edit-interview-form-submit-button") |> click
    assert current_path() == "/interviews/done"
    assert visible_page_text() =~ "your interview has been submitted!"

    # The interview record was updated
    assert Repo.get!(Interview, interview.id).recording == "#{interview.id}.webm"
  end

  test "faculty can vote on an interview", %{conn: conn} do
    q1 = insert :question, position: 1, eligible_for_voting: false
    q2 = insert :question, position: 2, eligible_for_voting: true
    user = insert :user, type: "faculty", min_votes_needed: 20
    insert :scheduled_task, user: user, command: "meet_voting_quota"
    # There are 3 interviews eligible for rating.
    insert :interview, question: q1, completed_at: Timex.now # ignored (wrong question)
    insert :interview, question: q2, completed_at: Timex.now
    insert :interview, question: q2, completed_at: Timex.now
    insert :interview, question: q2, completed_at: Timex.now
    insert :tag, text: "body", recommended: true
    insert :tag, text: "mind", recommended: true

    # Log in via the generic autologin URL; auto redirected to the vote page
    navigate_to session_path(conn, :login_from_uuid, user.uuid)
    assert current_path() =~ ~r"/interviews/\d+/votes/new"
    assert_selector(:css, ".play-video-container")
    # Skip: watching the video (which triggers the vote section to be shown)
    execute_script(" $('.js-ratings-container').show(); ")
    find_element(:css, ".vote-agreement-options input[value=\"3\"]")  |> click
    find_element(:css, ".vote-influenced-options input[value=\"2\"]") |> click
    execute_script(" $('.js-custom-tag-input').show(); ")
    find_element(:css, ".js-custom-tag-input") |> fill_field("spirit")
    find_all_elements(:css, ".js-select-tag")  |> List.first |> click
    find_element(:css, ".vote-submit-button")  |> click
    assert visible_page_text() =~ "Thanks! Your ratings have been saved."
    # Confirmation msg references a) the # I've rated, b) the total # available,
    # and c) the # I should try to complete (given my quota and the # available)
    assert visible_page_text() =~ "You've categorized 1 out of 3 interviews. Please try to complete at least 2 more."

    assert Repo.count(Vote) == 1
    assert Vote |> Repo.first |> tags_text |> Enum.sort == ["body", "spirit"]
  end

  # Cursory test that the other 2 faculty-facing pages are accessible
  test "faculty can send contact requests and view the results page", %{conn: conn} do
    assert Repo.count(ContactRequest) == 0
    user = insert :user, type: "faculty"

    navigate_to session_path(conn, :login_from_uuid, user.uuid) # log in
    find_element(:css, ".results-navbar-link") |> click
    assert current_path() == "/results"
    find_element(:css, ".help-navbar-link") |> click
    assert current_path() == "/help"
    find_element(:name, "contact_request[email]") |> fill_field("elmer.fudd")
    find_element(:name, "contact_request[body]")  |> fill_field("body body")
    find_element(:css, ".submit-contact-request") |> click
    # The form was incomplete; validation errors are displayed and nothing is saved.
    assert visible_page_text() =~ "Your message couldn't be submitted. Please check for errors below."
    assert Repo.count(ContactRequest) == 0
    find_element(:css, "select option[value=\"Share feedback\"]") |> click
    find_element(:css, ".submit-contact-request") |> click
    # This time the submission was accepted, saved, and emailed to the admins.
    assert visible_page_text() =~ "We've received your request and will reply soon."
    assert Repo.count(ContactRequest) == 1
    # We test that the email is sent in controller tests; it's hard to test in integration.
  end

  test "faculty timezone is auto detected and updated via AJAX", _ do
    # TODO
    # assert Repo.get!(Zb.User, user.id).utc_offset == 15
  end

  defp tags_text(vote) do
    vote |> Ecto.assoc(:tags) |> Repo.all |> Enum.map(fn(t) -> t.text end)
  end
end
