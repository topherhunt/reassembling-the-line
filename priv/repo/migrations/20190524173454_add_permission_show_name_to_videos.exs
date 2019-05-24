defmodule RTL.Repo.Migrations.AddPermissionShowNameToVideos do
  use Ecto.Migration

  def change do
    alter table(:videos) do
      add :permission_show_name, :bool
    end
  end
end
