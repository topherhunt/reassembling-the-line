defmodule Zb.Admin.UserController do
  use Zb.Web, :controller

  alias Zb.{User, Question}

  def index(conn, _params) do
    render conn, "index.html", users: users()
  end

  def show(conn, %{"id" => id}) do
    user = Repo.get!(User, id)
    render conn, "show.html", user: user,
      scheduled_tasks: load_scheduled_tasks(user),
      interviews: load_interviews(user),
      votes: load_votes(user)
  end

  def batch_new(conn, _params) do
    render conn, "batch_new.html"
  end

  def batch_create(_conn, _params) do
    raise "TODO"
    # Attempt uploading from .csv
    # If successful, redirect to dashboard with success message
  end

  # Helpers

  defp users do
    User
      |> order_by([u], asc: u.full_name)
      |> Repo.all
  end

  defp load_interviews(user) do
    user
      |> assoc(:interviews)
      |> join(:inner, [i], q in Question, i.question_id == q.id)
      |> order_by([i, q], asc: q.position)
      |> preload(:question)
      |> Repo.all
  end

  defp load_votes(user) do
    user
      |> assoc(:votes)
      |> order_by([v], asc: v.inserted_at)
      |> preload([:tags, [interview: :user]])
      |> Repo.all
  end

  defp load_scheduled_tasks(user) do
    user
      |> assoc(:scheduled_tasks)
      |> order_by([t], asc: t.command)
      |> preload(user: [interviews: :question])
      |> Repo.all
  end
end
