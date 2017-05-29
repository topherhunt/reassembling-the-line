defmodule EducateYour.SessionController do
  use EducateYour.Web, :controller

  alias EducateYour.{Auth, User}

  def login_from_uuid(conn, %{"uuid" => uuid}) do
    user = Repo.get_by!(User, uuid: uuid)
    conn
      |> Auth.login!(user)
      |> put_flash(:info, "Welcome back, #{user.full_name}!")
      |> redirect(to: home_path(conn, :index))
  end

  def logout(conn, _params) do
    conn
      |> Auth.logout!
      |> redirect(to: home_path(conn, :index))
  end
end
