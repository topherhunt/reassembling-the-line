defmodule Zb.Admin.ScheduledTaskController do
  use Zb.Web, :controller

  alias Zb.{User, ScheduledTask}

  def index(conn, _params) do
    render conn, "index.html", scheduled_tasks: all_scheduled_tasks()
  end

  # Helpers

  defp all_scheduled_tasks do
    ScheduledTask
      |> join(:inner, [t], u in User, t.user_id == u.id)
      |> order_by([t, u], asc: t.due_on_date, asc: t.command, asc: u.full_name)
      |> preload([user: [interviews: :question]])
      |> Repo.all
  end
end
