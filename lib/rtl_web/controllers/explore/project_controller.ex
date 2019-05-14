defmodule RTLWeb.Explore.ProjectController do
  use RTLWeb, :controller
  alias RTL.{Accounts, Projects}

  plug :load_project

  def show(conn, _params) do
    owner = Accounts.get_user_by!(admin_on_project: conn.assigns.project)

    conn
    |> load_demo_prompt_and_admin()
    |> render("show.html", owner: owner)
  end

  #
  # Internal
  #

  defp load_demo_prompt_and_admin(conn) do
    project = conn.assigns.project

    if project.uuid == "demo" do
      conn
      |> assign(:demo_prompt, Projects.get_prompt_by!(project: project))
      |> assign(:demo_admin, Accounts.get_user_by!(admin_on_project: project))
    else
      conn
    end
  end
end
