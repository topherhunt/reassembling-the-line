defmodule EducateYour.Repo.Migrations.CreateCodings do
  use Ecto.Migration

  def change do
    create table(:codings) do
      add :video_id, references(:videos, on_delete: :delete_all)
      add :updated_by_user_id, references(:users, on_delete: :nilify_all)
      timestamps()
    end

    create unique_index(:codings, :video_id)
  end
end
