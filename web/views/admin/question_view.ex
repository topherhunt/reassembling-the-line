defmodule Zb.Admin.QuestionView do
  use Zb.Web, :view

  alias Zb.Repo

  def ct_interviews_complete(question) do
    question |> Ecto.assoc(:interviews) |> Zb.Interview.completed |> Repo.count
  end

  def ct_interviews_total(question) do
    question |> Ecto.assoc(:interviews) |> Repo.count
  end
end
