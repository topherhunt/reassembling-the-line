defmodule RTL.Repo.Migrations.RenameCodingUpdatedByUserIdToCoderId do
  use Ecto.Migration

  def change do
    rename table(:codings), :updated_by_user_id, to: :coder_id
    create index(:codings, :coder_id)
  end
end
