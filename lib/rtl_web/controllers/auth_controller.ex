defmodule RTLWeb.AuthController do
  use RTLWeb, :controller
  alias RTL.Accounts
  alias RTLWeb.SessionPlugs
  alias RTL.Helpers, as: H
  require Logger

  # The Ueberauth plug magically does the following:
  # - creates a "login" action (/auth/login) that redirects to Auth0's login page
  # - converts Auth0's token into auth data and puts it in conn.assigns.ueberauth_*
  plug Ueberauth

  # After successful Auth0 login, the user is redirected here
  def auth0_callback(conn, _params) do
    if conn.assigns[:ueberauth_failure] do
      handle_auth_failure(conn)
    else
      handle_auth_success(conn)
    end
  end

  # TODO: I should require both a user-specific uuid and a global admin PW that's
  # only stored in the server env, not in the code or db.
  # Or maybe if I'm using a global secret pw, I don't need user uuid, just id.
  # TODO: Rename to force_login
  def force_login(conn, %{"uuid" => uuid}) do
    user = Accounts.get_user_by!(uuid: uuid)
    Logger.info("#force_login called; logging in as user #{user.id}.")

    conn
    |> SessionPlugs.login!(user)
    |> put_flash(:info, "Welcome back, #{user.full_name}!")
    |> redirect(to: Routes.manage_project_path(conn, :index))
  end

  def logout(conn, _params) do
    conn
    |> SessionPlugs.logout!()
    |> redirect(external: auth0_logout_url(conn))
  end

  #
  # Internal
  #

  defp handle_auth_success(conn) do
    auth = conn.assigns.ueberauth_auth
    user = Accounts.Services.FindOrCreateUserFromAuth.call(auth)

    conn
    |> SessionPlugs.login!(user)
    |> put_flash(:info, "Welcome back, #{user.full_name}!")
    |> redirect(to: "/")
  end

  defp handle_auth_failure(conn) do
    # I haven't yet seen a scenario where this is invoked, so I'll be lazy about it
    raise("auth0_callback received failure response: #{inspect(conn.assigns)}")
  end

  defp auth0_logout_url(conn) do
    domain = H.env!("AUTH0_DOMAIN")
    client_id = H.env!("AUTH0_CLIENT_ID")
    return_to = Routes.home_url(conn, :index)
    encoded_query = URI.encode_query(client_id: client_id, returnTo: return_to)
    "https://#{domain}/v2/logout?#{encoded_query}"
  end
end
