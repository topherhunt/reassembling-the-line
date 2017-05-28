defmodule Zb.Repo.Migrations.CreateScheduledTasks do
  use Ecto.Migration

  def change do
    create table(:scheduled_tasks) do
      add :user_id, references(:users, on_delete: :delete_all), null: false
      add :command, :string, null: false
      add :due_on_date, :date, null: false
      add :notified_at, :utc_datetime
      add :skipped_at, :utc_datetime
      timestamps
    end
  end
end
