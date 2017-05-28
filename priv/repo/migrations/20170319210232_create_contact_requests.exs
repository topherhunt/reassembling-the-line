defmodule Zb.Repo.Migrations.CreateContactRequests do
  use Ecto.Migration

  def change do
    create table(:contact_requests) do
      add :user_id, references(:users, on_delete: :delete_all)
      add :email, :string
      add :subject, :string
      add :body, :string
      timestamps()
    end
  end
end
