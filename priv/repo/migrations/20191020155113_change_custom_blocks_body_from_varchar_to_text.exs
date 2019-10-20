defmodule RTL.Repo.Migrations.ChangeCustomBlocksBodyFromVarcharToText do
  use Ecto.Migration

  def change do
    alter table(:custom_blocks) do
      modify :body, :text
    end
  end
end
