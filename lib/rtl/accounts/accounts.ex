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

  def get_user(id, filt \\ []), do: query_users([{:id, id} | filt]) |> Repo.one()
  def get_user!(id, filt \\ []), do: query_users([{:id, id} | filt]) |> Repo.one!()
  def get_user_by(filt), do: query_users(filt) |> Repo.first()
  def get_user_by!(filt), do: query_users(filt) |> Repo.first!()
  def get_users(filt \\ []), do: query_users(filt) |> Repo.all()
  def count_users(filt \\ []), do: query_users(filt) |> Repo.count()
  def query_users(filt), do: User |> User.filter(filt)

  def insert_user(params), do: new_user_changeset(params) |> Repo.insert()
  def insert_user!(params), do: new_user_changeset(params) |> Repo.insert!()
  def update_user(user, params), do: user_changeset(user, params) |> Repo.update()
  def update_user!(user, params), do: user_changeset(user, params) |> Repo.update!()
  def delete_user!(user), do: Repo.delete!(user)
  def delete_all_users, do: Repo.delete_all(User)

  def new_user_changeset(changes \\ %{}), do: User.changeset(%User{}, changes)
  def user_changeset(user, changes \\ %{}), do: User.changeset(user, changes)

  # Resetting the session_token voids all currently-active login sessions, so the user
  # can be sure that they aren't still logged in on some forgotten device.
  def reset_user_sessions(user), do: update_user!(user, %{session_token: ""})

  #
  # Login tokens
  #

  def get_login_token(email) do
    # Phoenix.Token gives us signed, salted, reversible, expirable tokens for free.
    Phoenix.Token.sign(RTLWeb.Endpoint, "login token salt", email)
  end

  def verify_login_token(token) do
    Phoenix.Token.verify(RTLWeb.Endpoint, "login token salt", token, max_age: 3600)
    # Will return {:ok, email} or {:error, _}
  end
end
