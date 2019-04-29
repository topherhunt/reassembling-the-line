defmodule RTLWeb.SentryPlugs do
  import Plug.Conn,
    only: [
      assign: 3,
      halt: 1,
      get_session: 2,
      put_session: 3,
      configure_session: 2
    ]

  import Phoenix.Controller, only: [put_flash: 3, redirect: 2]
  alias RTLWeb.Router.Helpers, as: Routes
  alias RTL.{Accounts, Sentry}

  #
  # Plugs
  #

  defp load_project(conn, _) do
    uuid = conn.params["project_uuid"]
    assign(conn, :project, Projects.get_project_by!(uuid: uuid))
  end

  defp load_prompt(conn, _) do
    uuid = conn.params["prompt_uuid"]
    assign(conn, :prompt, Projects.get_prompt_by!(uuid: uuid))
  end

  def ensure_logged_in(conn, _opts) do
    if conn.assigns.current_user do
      conn
    else
      conn
      |> put_flash(:error, "You must be logged in to access that page.")
      |> redirect(to: Routes.home_path(conn, :index))
      |> halt()
    end
  end

  def ensure_not_logged_in(conn, _opts) do
    if conn.assigns.current_user do
      conn
      |> put_flash(:error, "You are already logged in.")
      |> redirect(to: Routes.home_path(conn, :index))
      |> halt()
    else
      conn
    end
  end

  def ensure_superadmin(conn, _opts) do
    if Sentry.is_superadmin?(conn.assigns.current_user) do
      conn
    else
      redirect_with_permission_error(conn)
    end
  end

  def ensure_can_manage_project(conn, _) do
    user = conn.assigns.current_user
    project = conn.assigns.project

    if RTL.Sentry.can_manage_project?(user, project) do
      conn
    else
      redirect_with_permission_error(conn)
    end
  end

  #
  # Internal helpers
  #

  defp redirect_with_permission_error(conn) do
    conn
    |> put_flash(:error, "You don't have permission to access that page.")
    |> redirect(to: Routes.home_path(conn, :index))
    |> halt()
  end
end
