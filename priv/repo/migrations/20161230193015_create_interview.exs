defmodule Zb.Repo.Migrations.CreateInterview do
  use Ecto.Migration

  def change do
    create table(:interviews) do
      add :user_id, references(:users, on_delete: :delete_all)
      add :question_id, references(:questions, on_delete: :delete_all)
      add :completed_at, :utc_datetime
      add :recording, :string
      timestamps
    end

    create index(:interviews, [:user_id])
    create index(:interviews, [:question_id])
  end
end
