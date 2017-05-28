defmodule Zb.Admin.UserView do
  use Zb.Web, :view
  alias Zb.Repo

  def ct_interviews_complete(user) do
    user |> Ecto.assoc(:interviews) |> Zb.Interview.completed |> Repo.count
  end

  def ct_interviews_total(user) do
    user |> Ecto.assoc(:interviews) |> Repo.count
  end

  def ct_submitted_votes(user) do
    user |> Ecto.assoc(:votes) |> Repo.count
  end
end
