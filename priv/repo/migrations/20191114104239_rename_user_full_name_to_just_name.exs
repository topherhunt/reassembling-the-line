defmodule RTL.Repo.Migrations.RenameUserFullNameToJustName do
  use Ecto.Migration

  def change do
    rename table(:users), :full_name, to: :name
  end
end
