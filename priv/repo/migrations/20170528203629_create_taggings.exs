defmodule RTL.Repo.Migrations.CreateTaggings do
  use Ecto.Migration

  def change do
    create table(:taggings) do
      add :coding_id, references(:codings, on_delete: :delete_all)
      add :tag_id, references(:tags, on_delete: :delete_all)
      add :starts_at, :integer
      add :ends_at, :integer
      timestamps()
    end
  end
end
