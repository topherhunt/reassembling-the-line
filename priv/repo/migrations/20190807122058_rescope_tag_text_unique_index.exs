defmodule RTL.Repo.Migrations.RescopeTagTextUniqueIndex do
  use Ecto.Migration

  def change do
    drop unique_index(:tags, [:context, :text])
    drop unique_index(:tags, [:text])
    create unique_index(:tags, [:project_id, :text])

    alter table(:tags) do
      remove :context
    end
  end
end
