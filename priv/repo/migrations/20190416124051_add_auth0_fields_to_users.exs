defmodule RTL.Repo.Migrations.AddAuth0FieldsToUsers do
  use Ecto.Migration

  def change do
    alter table("users") do
      add :auth0_uid, :string
    end

    create index("users", [:auth0_uid], unique: true)
  end
end
