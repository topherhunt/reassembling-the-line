defmodule RTL.Repo.Migrations.AddSpeakerNameToVideos do
  use Ecto.Migration

  def change do
    alter table(:videos) do
      add :speaker_name, :string
      remove :source_name
    end
  end
end
