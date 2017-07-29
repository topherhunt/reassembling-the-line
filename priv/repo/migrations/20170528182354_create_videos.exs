defmodule EducateYour.Repo.Migrations.CreateVideos do
  use Ecto.Migration

  def change do
    create table(:videos) do
      add :title, :string
      add :source_name, :string
      add :source_url, :string
      add :recording_filename, :string
      add :thumbnail_filename, :string
      timestamps()
    end
  end
end
