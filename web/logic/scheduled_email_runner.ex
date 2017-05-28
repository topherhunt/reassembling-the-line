defmodule Zb.ScheduledEmailRunner do
  require Logger
  import Ecto
  alias Zb.{Repo, User, ScheduledTask, Email, Mailer, TaskComputer}

  def send_scheduled_emails do
    Logger.info "Starting send_scheduled_emails."
    User |> Repo.all |> Enum.map(fn(user) ->
      Logger.info "Checking tasks for user #{user.id}..."
      # If I have at least one DUE and UNPROCESSED task,
      # then notify me about my first DUE and INCOMPLETE task (if any).
      if TaskComputer.has_due_unprocessed_tasks?(user) do
        case TaskComputer.next_due_action(user) do
          {:do_interview, interview} ->
            Logger.info "User #{user.id}: Should do interview #{interview.id}."
            Email.time_to_do_interview(user, interview) |> Mailer.deliver_now
            mark_due_tasks_as_notified!(user)
          {:vote} ->
            Logger.info "User #{user.id}: Should vote."
            Email.time_to_vote(user) |> Mailer.deliver_now
            mark_due_tasks_as_notified!(user)
          {:nothing} ->
            Logger.info "User #{user.id}: Skipped; no due incomplete tasks."
            mark_due_tasks_as_skipped!(user)
        end
      end
    end)
  end

  def mark_due_tasks_as_notified!(user) do
    user
      |> assoc(:scheduled_tasks)
      |> ScheduledTask.due_now
      |> ScheduledTask.not_yet_notified
      |> Repo.update_all(set: [notified_at: Timex.now])
  end

  def mark_due_tasks_as_skipped!(user) do
    user
      |> assoc(:scheduled_tasks)
      |> ScheduledTask.due_now
      |> ScheduledTask.not_yet_notified
      |> Repo.update_all(set: [notified_at: Timex.now])
  end
end
