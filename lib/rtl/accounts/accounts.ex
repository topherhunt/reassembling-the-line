# Accounts context
# Serves as the boundary for all account-related db interactions.
# Code outside this context may not call functions within this context.
defmodule RTL.Accounts do
  import Ecto.Query, warn: false
  alias RTL.Repo
  alias RTL.Accounts.User

  def get_user!(id), do: Repo.get!(User, id)
  def get_user_by(params), do: Repo.get_by(User, params)
  def get_user_by!(params), do: Repo.get_by!(User, params)
  def get_all_users, do: Repo.all(User)
  def count_all_users, do: Repo.count(User)
  def insert_user(%{} = params), do: user_changeset(%User{}, params) |> Repo.insert()
  def update_user_signin_timestamp!(user), do:
    user_changeset(user, %{last_signed_in_at: Timex.now}) |> Repo.update!
  def delete_all_users, do: Repo.delete_all(User)
  def user_changeset(%User{} = user, changes), do: User.changeset(user, changes)
end
