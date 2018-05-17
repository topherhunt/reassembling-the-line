defmodule EducateYour.Repo do
  use Ecto.Repo, otp_app: :educate_your

  import Ecto.Query

  alias EducateYour.Repo

  # Simplify count queries where no join tables exist
  def count(query) do
    query |> select([table], count(table.id)) |> Repo.one
  end

  def first(query) do
    query |> limit(1) |> Repo.one
  end
end
