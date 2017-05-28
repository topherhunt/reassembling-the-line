defmodule Zb.Admin.ScheduledTaskView do
  use Zb.Web, :view

  alias Zb.TaskComputer

  def describe_command(task) do
    case TaskComputer.task_type(task) do
      :do_interview -> "Do interview #{TaskComputer.question_number(task)}"
      :vote -> "Meet voting quota"
    end
  end

  def describe_status(task) do
    cond do
      ! TaskComputer.due?(task) ->
        "<span class='text-muted'>not yet due</span>"
      TaskComputer.complete?(task) ->
        "<span class='text-success'>done</span>"
      true ->
        "<span class='text-warning'>overdue</span> #{notified_at_message(task)}"
    end |> raw
  end

  def notified_at_message(task) do
    if task.notified_at do
      "(emailed #{task.notified_at})"
    end
  end
end
