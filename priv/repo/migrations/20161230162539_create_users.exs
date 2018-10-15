defmodule RTL.Repo.Migrations.CreateUsers do
  use Ecto.Migration

  def change do
    create table(:users) do
      add :full_name, :string
      add :email, :string
      add :uuid, :string
      add :last_signed_in_at, :utc_datetime
      timestamps()
    end

    create unique_index(:users, [:email])
    create unique_index(:users, [:uuid])
  end
end
