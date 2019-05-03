defmodule RTL.Repo do
  use Ecto.Repo, otp_app: :rtl
  import Ecto.Query
  alias RTL.Repo

  def count(query), do: query |> select([t], count(t.id)) |> Repo.one()

  def any?(query), do: count(query) >= 1

  def first(query), do: query |> limit(1) |> Repo.one()

  # Raises if none found
  def first!(query), do: query |> limit(1) |> Repo.one!()

  # NOTE: Only works with SELECT statements
  def to_sql(query), do: Ecto.Adapters.SQL.to_sql(:all, Repo, query)
end
