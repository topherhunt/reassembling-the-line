defmodule RTL.Repo.Migrations.CreateProjectAdminJoins do
  use Ecto.Migration

  def change do
    create table(:project_admin_joins) do
      add :project_id, references(:projects, on_delete: :delete_all)
      add :admin_id, references(:users, on_delete: :delete_all)
      timestamps()
    end

    create index(:project_admin_joins, [:project_id])
    create index(:project_admin_joins, [:admin_id])
    create unique_index(:project_admin_joins, [:project_id, :admin_id])
  end
end
