defmodule RTL.Repo.Migrations.ChangeTimingsStartsAtAndEndsAtToDecimals do
  use Ecto.Migration

  def change do
    alter table(:taggings) do
      modify :starts_at, :float
      modify :ends_at, :float
    end
  end
end
