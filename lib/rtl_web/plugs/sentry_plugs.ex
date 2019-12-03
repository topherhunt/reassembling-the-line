defmodule RTLWeb.SentryPlugs do
  import Plug.Conn
  import Phoenix.Controller, only: [put_flash: 3, redirect: 2]
  alias RTLWeb.Router.Helpers, as: Routes
  alias RTL.Sentry
  alias RTL.Projects

  #
  # Plugs
  #

  def load_project(conn, _) do
    uuid = conn.params["project_uuid"]
    project = Projects.get_project_by!(uuid: uuid, preload: :custom_blocks)
    assign(conn, :project, project)
  end

  def load_prompt(conn, _) do
    prompt = Projects.get_prompt_by!(uuid: conn.params["prompt_uuid"])
    assign(conn, :prompt, prompt)
  end

  def ensure_logged_in(conn, _opts) do
    if conn.assigns.current_user do
      conn
    else
      return_to = "#{conn.request_path}?#{conn.query_string}"

      conn
      |> put_resp_cookie("return_to", return_to)
      |> put_flash(:error, "You must be logged in to access that page.")
      |> redirect(to: Routes.auth_path(conn, :login))
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

    if Sentry.can_manage_project?(user, project) do
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
