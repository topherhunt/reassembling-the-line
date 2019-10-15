defmodule RTL.Repo.Migrations.AddEmailAuthFieldsToUsers do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add :session_token, :string
      add :last_visit_date, :date
      remove :uuid
      remove :auth0_uid
      remove :last_signed_in_at
    end
  end
end
