defmodule Zb.Admin.QuestionController do
  use Zb.Web, :controller

  alias Zb.Question

  def index(conn, _params) do
    questions = Question |> order_by([q], asc: q.position) |> Repo.all
    render conn, "index.html", questions: questions
  end
end
