defmodule RTL.Repo.Migrations.AddPermissionToVideos do
  use Ecto.Migration

  def change do
    alter table(:videos) do
      add :permission, :string
    end

    create index(:videos, [:permission])
  end
end
