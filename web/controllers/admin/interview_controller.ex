defmodule Zb.Admin.InterviewController do
  use Zb.Web, :controller

  alias Zb.Interview

  def index(conn, _params) do
    render conn, "index.html", interviews: all_interviews()
  end

  def show(conn, %{"id" => id}) do
    interview = load_interview(id)
    render conn, "show.html",
      interview: interview,
      votes: load_votes(interview)
  end

  # Helpers

  defp all_interviews do
    Interview
      |> preload([:user, :question])
      |> Repo.all
  end

  defp load_interview(id) do
    Interview |> Repo.get!(id) |> Repo.preload([:user, :question])
  end

  defp load_votes(interview) do
    interview
      |> assoc(:votes)
      |> preload([:user, :tags])
      |> Repo.all
  end
end
