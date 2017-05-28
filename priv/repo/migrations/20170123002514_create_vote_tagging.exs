defmodule Zb.Repo.Migrations.CreateVoteTagging do
  use Ecto.Migration

  def change do
    create table(:vote_taggings) do
      add :vote_id, references(:votes, on_delete: :delete_all)
      add :tag_id, references(:tags, on_delete: :delete_all)
      timestamps
    end

    create index(:vote_taggings, [:vote_id])
    create index(:vote_taggings, [:tag_id])
  end
end
