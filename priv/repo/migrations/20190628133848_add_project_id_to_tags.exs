defmodule RTL.Repo.Migrations.AddProjectIdToTags do
  use Ecto.Migration

  def up do
    alter table(:tags) do
      add :project_id, references(:projects, on_delete: :delete_all)
    end

    create index(:tags, [:project_id])

    execute("UPDATE tags SET project_id = (SELECT pm.project_id FROM prompts pm JOIN videos v ON pm.id = v.prompt_id JOIN codings c ON v.id = c.video_id JOIN taggings ti ON c.id = ti.coding_id WHERE ti.tag_id = tags.id)")

    alter table(:tags) do
      modify :project_id, :bigint, null: false
    end
  end

  def down do
    alter table(:tags) do
      remove :project_id
    end
  end
end
