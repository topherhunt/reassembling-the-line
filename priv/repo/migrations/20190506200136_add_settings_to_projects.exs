defmodule RTL.Repo.Migrations.AddSettingsToProjects do
  use Ecto.Migration

  def change do
    alter table(:projects) do
      add :settings, :jsonb
    end
  end
end
