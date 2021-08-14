defmodule RTLWeb.Admin.VideoImportController do
  use RTLWeb, :controller
  alias RTL.{Projects, Videos}

  plug :load_project
  plug :ensure_can_manage_project

  def new(conn, _params) do
    render conn, "new.html", prompts: load_prompts(conn), error: nil
  end

  def create(conn, %{"prompt_id" => prompt_id, "videos_json" => videos_json}) do
    prompt = Projects.get_prompt!(prompt_id, project: conn.assigns.project)

    try do
      videos = videos_json
      |> Jason.decode!()
      |> Enum.map(fn(attrs) ->
        attrs = Map.merge(attrs, %{"prompt_id" => prompt.id})
        Videos.insert_video!(attrs, :generic)
      end)

      conn
      |> put_flash(:info, gettext("Imported %{num} videos.", num: length(videos)))
      |> redirect(to: Routes.admin_project_path(conn, :show, conn.assigns.project))
    rescue e ->
      render conn, "new.html", prompts: load_prompts(conn), error: e
    end
  end

  #
  # Helpers
  #

  defp load_prompts(conn) do
    Projects.get_prompts(project: conn.assigns.project)
  end
end
