defmodule Zb.TaskComputer do

  import Ecto
  import Ecto.Query

  alias Zb.{Repo, User, ScheduledTask}

  def has_due_unprocessed_tasks?(user) do
    user
      |> assoc(:scheduled_tasks)
      |> ScheduledTask.due_now
      |> ScheduledTask.not_yet_notified
      |> Repo.count > 0
  end

  def next_due_action(user) do
    if task = List.first(due_incomplete_tasks(user)) do
      case task_type(task) do
        :do_interview -> {:do_interview, interview_for(task)}
        :vote -> {:vote}
      end
    else
      {:nothing}
    end
  end

  def next_available_action(user) do
    if task = List.first(all_incomplete_tasks(user)) do
      case task_type(task) do
        :do_interview -> {:do_interview, interview_for(task)}
        :vote -> {:vote}
      end
    else
      {:nothing}
    end
  end

  def due_incomplete_tasks(user) do
    all_incomplete_tasks(user)
      |> Enum.filter(fn(task) -> task.due_on_date <= Timex.today end)
  end

  def all_incomplete_tasks(user) do
    user
      |> assoc(:scheduled_tasks)
      |> order_by([t], asc: t.command)
      |> preload([user: [interviews: :question]])
      |> Repo.all
      |> Enum.filter(fn(task) -> ! complete?(task) end)
  end

  def due?(task) do
    task.due_on_date <= Timex.today
  end

  def complete?(task) do
    case task_type(task) do
      :do_interview -> interview_for(task).completed_at != nil
      :vote         -> ! User.more_votes_needed?(task.user)
    end
  end

  def interview_for(task) do
    task.user.interviews |> Enum.find(fn(i) ->
      i.question.position == question_number(task)
    end) || raise("No interview found for task #{task.id}!")
  end

  # Attribute helpers

  def question_number(task) do
    String.split(task.command, ":") |> Enum.at(1) |> String.to_integer
  end

  def task_type(task) do
    if task.command =~ "do_interview" do
      :do_interview
    else
      :vote
    end
  end
end
