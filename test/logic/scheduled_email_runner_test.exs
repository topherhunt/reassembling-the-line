defmodule Zb.ScheduledEmailRunnerTest do
  use Zb.ModelCase, async: true
  import Zb.ScheduledTask, only: [due_now: 1, not_yet_due: 1, notification_sent: 1, not_yet_notified: 1]
  alias Zb.{ScheduledTask, ScheduledEmailRunner, Email}

  test "#send_scheduled_emails test 1: Second interview is due" do
    # A) interviews 1 and 2 are now due. One person hasn't yet done i1; one person
    #    has completed both i1 and i2 and thus won't get an email.
    q1 = insert :question, position: 1
    q2 = insert :question, position: 2, eligible_for_voting: true
    u1 = insert :user, min_votes_needed: 2
    u2 = insert :user, min_votes_needed: 2
    u3 = insert :user, min_votes_needed: 2
    # u1 has completed the first interview as expected
           add_interview(user: u1, question: q1, completed_at: Timex.now)
    u1i2 = add_interview(user: u1, question: q2, completed_at: nil)
    # u2 hasn't completed either interview
    u2i1 = add_interview(user: u2, question: q1, completed_at: nil)
           add_interview(user: u2, question: q2, completed_at: nil)
    # u3 has completed both interviews
           add_interview(user: u3, question: q1, completed_at: Timex.now)
           add_interview(user: u3, question: q2, completed_at: Timex.now)
    # All three users have the same due dates
    [u1, u2, u3] |> Enum.each(fn(user)  ->
      add_task(user: user, command: "do_interview:1", due_on_date: yesterday())
      add_task(user: user, command: "do_interview:2", due_on_date: today())
      add_task(user: user, command: "meet_voting_quota", due_on_date: tomorrow())
    end)

    ScheduledEmailRunner.send_scheduled_emails
    # The right emails were sent
    assert delivered_email? Email.time_to_do_interview(u1, u1i2)
    assert delivered_email? Email.time_to_do_interview(u2, u2i1)
    assert length(emails_delivered_to(u2)) == 1 # sanity check
    assert length(emails_delivered_to(u3)) == 0
    # All due tasks are marked as notified, but yet-to-be-due tasks aren't.
    assert Repo.count(ScheduledTask) == 9 # 3 for each of 3 users
    assert Repo.count(ScheduledTask |> due_now |> notification_sent) == 6
    assert Repo.count(ScheduledTask |> not_yet_due |> not_yet_notified) == 3
  end

  test "#send_scheduled_emails test 2: Voting is due" do
    # B) voting is now due. One person is still missing i2; one person has already
    #    met their quota and thus won't be asked to vote.
    q1 = insert :question, position: 1
    q2 = insert :question, position: 2, eligible_for_voting: true
    u1 = insert :user, min_votes_needed: 2
    u2 = insert :user, min_votes_needed: 2
    u3 = insert :user, min_votes_needed: 2
    # u1 has completed their interviews, and started voting
    u1i1 = add_interview(user: u1, question: q1, completed_at: Timex.now)
    u1i2 = add_interview(user: u1, question: q2, completed_at: Timex.now)
    # u2 still needs to complete interview 2
    u2i1 = add_interview(user: u2, question: q1, completed_at: Timex.now)
    u2i2 = add_interview(user: u2, question: q2, completed_at: nil)
    # u3 has completed both interviews AND finished voting
           add_interview(user: u3, question: q1, completed_at: Timex.now)
           add_interview(user: u3, question: q2, completed_at: Timex.now)
    # Now add the votes
    insert :vote, user: u1, interview: u2i1
    insert :vote, user: u3, interview: u1i1
    insert :vote, user: u3, interview: u1i2
    # All three users have the same due dates
    [u1, u2, u3] |> Enum.each(fn(user)  ->
      add_task(user: user, command: "do_interview:1", due_on_date: yesterday())
      add_task(user: user, command: "do_interview:2", due_on_date: yesterday())
      add_task(user: user, command: "meet_voting_quota", due_on_date: today())
    end)

    ScheduledEmailRunner.send_scheduled_emails
    # The right emails were sent
    assert delivered_email? Email.time_to_vote(u1)
    assert delivered_email? Email.time_to_do_interview(u2, u2i2)
    assert length(emails_delivered_to(u3)) == 0
    # All due tasks are now marked as processed
    assert Repo.count(ScheduledTask) == 9 # 3 for each of 3 users
    assert Repo.count(ScheduledTask |> due_now |> notification_sent) == 9
    assert Repo.count(ScheduledTask |> not_yet_notified) == 0
  end

  # Helpers

  defp yesterday do
    Timex.today |> Timex.shift(days: -1)
  end

  defp today do
    Timex.today
  end

  defp tomorrow do
    Timex.today |> Timex.shift(days: 1)
  end

  defp add_interview(opts) do
    insert :interview, opts
  end

  defp add_task(opts) do
    insert :scheduled_task, opts
  end
end
