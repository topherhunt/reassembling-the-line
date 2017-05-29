defmodule EducateYour.Repo.Migrations.CreateTags do
  use Ecto.Migration

  def change do
    create table(:tags) do
      add :context, :string
      add :text, :string
      timestamps()
    end

    create unique_index(:tags, [:text])
  end
end
