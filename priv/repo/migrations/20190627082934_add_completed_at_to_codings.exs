defmodule RTL.Repo.Migrations.AddCompletedAtToCodings do
  use Ecto.Migration

  def change do
    alter table(:codings) do
      add :completed_at, :utc_datetime
    end
  end
end
