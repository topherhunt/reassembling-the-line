defmodule Zb.Repo.Migrations.CreateVote do
  use Ecto.Migration

  def change do
    create table(:votes) do
      add :user_id, references(:users, on_delete: :delete_all)
      add :interview_id, references(:interviews, on_delete: :delete_all)
      add :vote_agreement, :integer
      add :vote_influenced, :integer
      timestamps
    end

    create index(:votes, [:user_id])
    create index(:votes, [:interview_id])
  end
end
