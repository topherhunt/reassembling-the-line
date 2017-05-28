defmodule Zb.Repo do
  use Ecto.Repo, otp_app: :zb

  import Ecto.Query

  alias Zb.Repo

  # Simplify count queries where no join tables exist: query |> Repo.count
  def count(query) do
    query |> select([table], count(table.id)) |> Repo.one
  end

  def first(query) do
    query |> limit(1) |> Repo.one
  end
end
