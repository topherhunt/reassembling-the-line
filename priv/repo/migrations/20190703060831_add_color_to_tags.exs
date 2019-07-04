defmodule RTL.Repo.Migrations.AddColorToTags do
  use Ecto.Migration

  def change do
    alter table(:tags) do
      add :color, :string
    end
  end
end
