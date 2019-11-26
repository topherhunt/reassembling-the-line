defmodule RTL.Repo.Migrations.ChangePromptHtmlToText do
  use Ecto.Migration

  def change do
    alter table(:prompts) do
      modify :html, :text
    end
  end
end
