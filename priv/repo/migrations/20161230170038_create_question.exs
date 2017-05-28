defmodule Zb.Repo.Migrations.CreateQuestion do
  use Ecto.Migration

  def change do
    create table(:questions) do
      add :position, :integer, null: false
      add :text, :string, null: false
      add :eligible_for_voting, :boolean, default: false, null: false
      timestamps
    end
  end
end
