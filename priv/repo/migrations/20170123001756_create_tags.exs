defmodule Zb.Repo.Migrations.CreateTags do
  use Ecto.Migration

  def change do
    create table(:tags) do
      add :text, :string
      add :recommended, :boolean, default: :false, null: false
      timestamps
    end

    create unique_index(:tags, [:text])
  end
end
