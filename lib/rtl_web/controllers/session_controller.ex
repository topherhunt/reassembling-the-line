defmodule RTLWeb.SessionController do
  use RTLWeb, :controller
  alias RTL.Accounts
  alias RTLWeb.Auth

  def login_from_uuid(conn, %{"uuid" => uuid}) do
    user = Accounts.get_user_by!(uuid: uuid)

    conn
    |> Auth.login!(user, remember_me: false)
    |> put_flash(:info, "Welcome back, #{user.full_name}!")
    |> redirect(to: Routes.home_path(conn, :index))
  end

  def logout(conn, _params) do
    conn
    |> Auth.logout!()
    |> redirect(to: Routes.home_path(conn, :index))
  end
end
