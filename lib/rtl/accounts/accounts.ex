# Accounts context
# Serves as the boundary for all account-related db interactions.
# Code outside this context may not call functions within this context.
defmodule RTL.Accounts do
  import Ecto.Query, warn: false
  alias RTL.Repo
  alias RTL.Accounts.{User, Nonce, LoginTry}

  #
  # User schema
  #

  # TODO: Remove these, use User.filter() and pipe to Repo functions instead
  def get_user(id, filt \\ []), do: query_users([{:id, id} | filt]) |> Repo.one()
  def get_user!(id, filt \\ []), do: query_users([{:id, id} | filt]) |> Repo.one!()
  def get_user_by(filt), do: query_users(filt) |> Repo.first()
  def get_user_by!(filt), do: query_users(filt) |> Repo.first!()
  def get_users(filt \\ []), do: query_users(filt) |> Repo.all()
  def count_users(filt \\ []), do: query_users(filt) |> Repo.count()
  def query_users(filt), do: User |> User.filter(filt)

  # On insert & update, you must specify the context (:owner or :admin).
  def insert_user(prms, ctx), do: %User{} |> User.changeset(prms, ctx) |> Repo.insert()
  def insert_user!(prms, ctx), do: %User{} |> User.changeset(prms, ctx) |> Repo.insert!()
  def update_user(user, prms, ctx), do: user |> User.changeset(prms, ctx) |> Repo.update()
  def update_user!(user, prms, ctx), do: user |> User.changeset(prms, ctx) |> Repo.update!()
  def delete_user!(user), do: Repo.delete!(user)

  # Resetting the session_token voids all currently-active login sessions, so the user
  # can be sure that they aren't still logged in on some forgotten device.
  def reset_user_sessions(user), do: update_user!(user, %{session_token: ""}, :admin)

  def password_correct?(user_or_nil, password) do
    case Argon2.check_pass(user_or_nil, password) do
      {:ok, _user} -> true
      {:error, _msg} -> false
    end
  end

  #
  # Tokens
  #

  # Phoenix.Token gives us signed, salted, reversible, expirable tokens for free.
  # To protect from replay attacks, we embed a nonce id in each (otherwise stateless)
  # token. The nonce is validated at parsing time. Be sure to explicitly invalidate
  # the token when it's no longer needed!
  #
  # Usage:
  #   # Generate a single-use token:
  #   token = Accounts.create_token!({:reset_password, user_id})
  #   # Later, parse and validate the token:
  #   {:ok, {:reset_password, user_id}} = Accounts.parse_token(token)
  #   # IMPORTANT: Destroy the token as soon as you no longer need it.
  #   Accounts.invalidate_token!(token)

  @endpoint RTLWeb.Endpoint
  @salt "HenCSi83BjsltZhJVa6"
  @one_week 60*60*24*7

  def create_token!(data) do
    nonce = insert_nonce!()
    wrapped_data = %{data: data, nonce_id: nonce.id}
    Phoenix.Token.sign(@endpoint, @salt, wrapped_data)
  end

  def parse_token(token) do
    # Some use cases (e.g. the welcome email) need a token with a 2+ day lifetime.
    # Thanks to the nonces I don't see much harm in this.
    case Phoenix.Token.verify(@endpoint, @salt, token, max_age: @one_week) do
      {:ok, map} ->
        case valid_nonce?(map.nonce_id) do
          true -> {:ok, map.data}
          false -> {:error, "invalid nonce"}
        end

      {:error, msg} -> {:error, msg}
    end
  end

  def invalidate_token!(token) do
    {:ok, map} = Phoenix.Token.verify(@endpoint, @salt, token, max_age: :infinity)
    delete_nonce!(map.nonce_id)
    :ok
  end

  #
  # Nonces
  #

  def insert_nonce! do
    Nonce.admin_changeset(%Nonce{}, %{}) |> Repo.insert!()
  end

  def valid_nonce?(id) do
    Repo.get(Nonce, id) != nil
  end

  def delete_nonce!(id) do
    Repo.get!(Nonce, id) |> Repo.delete!()
  end

  #
  # Login tries
  #

  def insert_login_try!(email) do
    LoginTry.admin_changeset(%LoginTry{}, %{email: email}) |> Repo.insert!()
  end

  def count_recent_login_tries(email) do
    email = String.downcase(email)
    time = Timex.now() |> Timex.shift(minutes: -15)
    LoginTry |> where([t], t.email == ^email and t.inserted_at >= ^time) |> Repo.count()
  end

  def clear_login_tries(email) do
    email = String.downcase(email)
    LoginTry |> where([t], t.email == ^email) |> Repo.delete_all()
  end
end
