defmodule RTL.Repo.Migrations.AddFieldsAndTablesForPasswordLogin do
  use Ecto.Migration

  def up do
    alter table(:users) do
      add :confirmed_at, :utc_datetime
      add :password_hash, :text
    end

    # Assign all grandfathered users a dummy password to ensure the record is valid.
    execute "UPDATE users SET password_hash = '$argon2id$v=19$m=131072,t=8,p=4$rD+Fai2Qmt8nJQpNwuww0g$hw80PBKNtc6n1+aeW2fJWVtM+dHr1V1WQN4oH9gx39A' WHERE password_hash IS NULL;"

    # Mark all grandfathered users as confirmed so there's no hassle next time they log in.
    execute "UPDATE users SET confirmed_at = NOW() WHERE confirmed_at IS NULL;"

    # Set a NOT NULL constraint on certain user fields that should always be populated.
    alter table(:users) do
      modify :name, :text, null: false
      modify :email, :text, null: false
      modify :password_hash, :text, null: false
    end

    create table(:nonces) do
      timestamps()
    end

    create table(:login_tries) do
      add :email, :text, null: false
      timestamps()
    end

    create index(:login_tries, [:email, :inserted_at])
  end

  def down do
    alter table(:users) do
      remove :confirmed_at
      remove :password_hash
    end

    drop table(:login_tries)

    drop table(:nonces)
  end
end
