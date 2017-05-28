defmodule Zb.TaskComputerTest do
  use Zb.ModelCase, async: true

  alias Zb.TaskComputer

  test "#has_due_unprocessed_tasks returns true if any due, unprocessed tasks" do
    user = insert :user
    add_task(user: user, due_on_date: today(), notified_at: Timex.now)
    assert TaskComputer.has_due_unprocessed_tasks?(user) == false
    add_task(user: user, due_on_date: today(), notified_at: nil)
    assert TaskComputer.has_due_unprocessed_tasks?(user) == true
  end

  test "#next_due_action returns my first due, incomplete interview" do
    user = insert :user
    q1 = insert :question, position: 1
    q2 = insert :question, position: 2
    q3 = insert :question, position: 3
         add_interview(user: user, question: q1, completed_at: Timex.now)
    i2 = add_interview(user: user, question: q2, completed_at: nil)
         add_interview(user: user, question: q3, completed_at: nil)
         add_interview(question: q1, completed_at: nil) # another user's
    add_task(user: user, command: "do_interview:1", due_on_date: yesterday())
    add_task(user: user, command: "do_interview:2", due_on_date: today())
    add_task(user: user, command: "do_interview:3", due_on_date: tomorrow())
    add_task(user: user, command: "meet_voting_quota", due_on_date: tomorrow())

    {:do_interview, target} = TaskComputer.next_due_action(user)
    assert target.id == i2.id
  end

  test "#next_due_action returns :vote if that's due and incomplete" do
    user = insert :user, min_votes_needed: 2
    q1 = insert :question, position: 1
    add_interview(user: user, question: q1, completed_at: Timex.now)
    add_task(user: user, command: "do_interview:1", due_on_date: yesterday())
    # Tasks are included even if they're skipped
    add_task(user: user, command: "meet_voting_quota", due_on_date: yesterday(), skipped_at: Timex.now)

    assert TaskComputer.next_due_action(user) == {:vote}
  end

  test "#next_due_action returns nil if no due, incomplete tasks" do
    user = insert :user
    q1 = insert :question, position: 1
    add_interview(user: user, question: q1, completed_at: Timex.now)
    add_task(user: user, command: "do_interview:1", due_on_date: yesterday()) # completed
    add_task(user: user, command: "meet_voting_quota", due_on_date: tomorrow()) # not due

    assert TaskComputer.next_due_action(user) == {:nothing}
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
