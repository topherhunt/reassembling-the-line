defmodule RTL.Repo.Migrations.AddPromptIdToVideos do
  use Ecto.Migration

  def change do
    alter table(:videos) do
      add :prompt_id, references(:prompts, on_delete: :delete_all)
    end
    
    create index(:videos, [:prompt_id])
  end
end
