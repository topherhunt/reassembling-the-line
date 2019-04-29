defmodule RTL.Repo.Migrations.CreatePrompts do
  use Ecto.Migration

  def change do
    create table(:prompts) do
      add :project_id, references(:projects, on_delete: :delete_all)
      add :uuid, :string, null: false
      add :html, :string, null: false
      timestamps()
    end

    create index(:prompts, [:project_id])
    create unique_index(:prompts, [:uuid])
  end
end
