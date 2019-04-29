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

  def get_user(id, filt \\ []), do: get_user_by(Keyword.merge([id: id], filt))

  def get_user!(id, filt \\ []), do: get_user_by!(Keyword.merge([id: id], filt))

  def get_user_by(filt \\ []), do: User |> User.filter(filt) |> Repo.first()

  def get_user_by!(filt \\ []), do: User |> User.filter(filt) |> Repo.first!()

  def get_users(filt \\ []), do: User |> User.filter(filt) |> Repo.all()

  def count_users(filt \\ []), do: User |> User.filter(filt) |> Repo.count()

  def insert_user(params), do: new_user_changeset(params) |> Repo.insert()

  def insert_user!(params), do: new_user_changeset(params) |> Repo.insert!()

  def update_user(user, params), do: user_changeset(user, params) |> Repo.update()

  def update_user!(user, params), do: user_changeset(user, params) |> Repo.update!()

  def delete_user!(user), do: Repo.delete!(user)

  def delete_all_users, do: Repo.delete_all(User)

  def new_user_changeset(changes \\ %{}), do: User.changeset(%User{}, changes)

  def user_changeset(user, changes \\ %{}), do: User.changeset(user, changes)
end
