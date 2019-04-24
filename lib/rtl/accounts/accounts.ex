# Accounts context
# Serves as the boundary for all account-related db interactions.
# Code outside this context may not call functions within this context.
defmodule RTL.Accounts do
  import Ecto.Query, warn: false
  alias RTL.Repo
  alias RTL.Accounts.User

  #
  # User schema
  #

  # TODO: Something is weird about this boundary. Maybe try `get_user(id)` (no
  # filters allowed) and `get_user_by(filters)`.

  def get_user(id), do: Repo.get(User, id)

  def get_user!(id), do: Repo.get!(User, id)

  def get_user_by(filters \\ []), do: User |> User.filter(filters) |> Repo.first()

  def get_user_by!(filters \\ []), do: User |> User.filter(filters) |> Repo.first!()

  def get_users(filters \\ []), do:  User |> User.filter(filters) |> Repo.all()

  def count_users(filters \\ []), do: User |> User.filter(filters) |> Repo.count()

  def insert_user(params), do: new_user_changeset(params) |> Repo.insert()

  def insert_user!(params), do: new_user_changeset(params) |> Repo.insert!()

  def update_user(user, params), do: user_changeset(user, params) |> Repo.update()

  def update_user!(user, params), do: user_changeset(user, params) |> Repo.update!()

  def delete_user!(user), do: Repo.delete!(user)

  def delete_all_users, do: Repo.delete_all(User)

  def new_user_changeset(changes \\ %{}), do: User.changeset(%User{}, changes)

  def user_changeset(user, changes \\ %{}), do: User.changeset(user, changes)
end
