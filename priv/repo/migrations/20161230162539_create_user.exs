defmodule Zb.Repo.Migrations.CreateUser do
  use Ecto.Migration

  def change do
    create table(:users) do
      add :type, :string
      add :email, :string
      add :password_hash, :string
      add :uuid, :string
      add :full_name, :string
      add :utc_offset, :integer
      add :min_votes_needed, :integer, null: false
      add :last_signed_in_at, :utc_datetime
      timestamps
    end

    create index(:users, [:type])
    create unique_index(:users, [:email])
    create unique_index(:users, [:uuid])
  end
end
