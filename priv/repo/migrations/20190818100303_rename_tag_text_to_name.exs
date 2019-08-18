defmodule RTL.Repo.Migrations.RenameTagTextToName do
  use Ecto.Migration

  def change do
    rename table(:tags), :text, to: :name
  end
end
