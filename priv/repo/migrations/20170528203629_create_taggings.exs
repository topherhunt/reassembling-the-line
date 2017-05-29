defmodule EducateYour.Repo.Migrations.CreateTaggings do
  use Ecto.Migration

  def change do
    create table(:taggings) do
      add :video_id, references(:videos, on_delete: :delete_all)
      add :coding_id, references(:codings, on_delete: :delete_all)
      add :tag_id, references(:tags, on_delete: :delete_all)
      timestamps()
    end
  end
end
