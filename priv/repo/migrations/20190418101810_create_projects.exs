defmodule RTL.Repo.Migrations.CreateProjects do
  use Ecto.Migration

  def change do
    create table(:projects) do
      add :uuid, :string, null: false
      add :name, :string, null: false
      add :deactivated, :boolean, default: false
      timestamps()
    end

    create unique_index(:projects, [:uuid])
  end
end
