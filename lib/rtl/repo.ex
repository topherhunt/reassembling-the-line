defmodule RTL.Repo do
  use Ecto.Repo, otp_app: :rtl
  import Ecto.Query
  alias RTL.Repo

  # Simplify count queries where no join tables exist
  def count(query) do
    query |> select([table], count(table.id)) |> Repo.one
  end

  def first(query) do
    query |> limit(1) |> Repo.one
  end

  # NOTE: Only works with select statements.
  def to_sql(query) do
    Ecto.Adapters.SQL.to_sql(:all, Repo, query)
  end
end
