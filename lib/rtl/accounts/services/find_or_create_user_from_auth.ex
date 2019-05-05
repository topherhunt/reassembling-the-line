defmodule RTL.Accounts.Services.FindOrCreateUserFromAuth do
  alias RTL.Accounts
  require Logger

  def call(auth) do
    uid = auth.uid || blowup(auth, "UID is required")
    name = get_name(auth) || blowup(auth, "name is required")
    email = auth.info.email || blowup(auth, "email is required")

    cond do
      user = Accounts.get_user_by(auth0_uid: uid) ->
        Logger.info("Auth: Logged in user #{user.id} (#{user.email}) by auth0_uid #{uid}.")
        user

      user = Accounts.get_user_by(email: email) ->
        ensure_user_doesnt_have_auth0_uid(user, auth)
        user = Accounts.update_user!(user, %{auth0_uid: uid})
        Logger.info("Auth: Mapped user #{user.id} (#{user.email}) to auth0_uid #{uid}.")
        user

      # No user was found, we'll have to create one.
      true ->
        user = Accounts.insert_user!(%{auth0_uid: uid, full_name: name, email: email})
        Logger.info("Auth: Created user #{user.id} (#{user.email}) for auth0_uid #{uid}.")
        user
    end
  end

  defp get_name(auth) do
    # Different providers use auth.info.name differently:
    # - Auth0 db connection puts the email address there
    # - Google puts your full name there
    if String.contains?(auth.info.name, "@") do
      auth.info.nickname
    else
      auth.info.name
    end
  end

  # Just a sanity check
  defp ensure_user_doesnt_have_auth0_uid(user, auth) do
    if user.auth0_uid != nil do
      blowup(auth, "User #{user.id} matched by email, but already has an auth0_uid")
    end
  end

  defp blowup(auth, message) do
    raise "Invalid auth data: #{message}. The full auth data: #{inspect(auth)}"
  end
end
