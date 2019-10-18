defmodule RTL.Repo.Migrations.CreateCustomBlocks do
  use Ecto.Migration

  def change do
    create table(:custom_blocks) do
      add :project_id, references(:projects, on_delete: :delete_all), null: false
      add :label, :string, null: false
      add :body, :string
      timestamps()
    end

    create index(:custom_blocks, [:project_id])
  end
end
