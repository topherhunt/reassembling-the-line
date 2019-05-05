defmodule RTLWeb.Explore.ProjectController do
  use RTLWeb, :controller
  alias RTL.{Accounts, Projects, Videos}

  plug :load_project

  def show(conn, _params) do
    count_videos = Videos.count_videos(project: conn.assigns.project)

    conn
    |> load_demo_prompt_and_admin()
    |> render("show.html", count_videos: count_videos)
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
