defmodule EducateYour.Repo.Migrations.AddTextIndexToTags do
  use Ecto.Migration

  def change do
    create unique_index(:tags, [:text])
  end
end
