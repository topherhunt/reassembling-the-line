defmodule RTLWeb.Admin.PromptController do
  use RTLWeb, :controller
  alias RTL.Projects

  plug :load_project
  plug :ensure_can_manage_project
  # Convert :uuid param to :prompt_uuid for consistency / clarity
  plug :rename_prompt_uuid when action in [:show, :edit, :update, :delete]
  plug :load_prompt when action in [:show, :edit, :update, :delete]

  def show(conn, _params) do
    render conn, "show.html"
  end

  def new(conn, _params) do
    changeset = Projects.new_prompt_changeset()
    render conn, "new.html", changeset: changeset
  end

  def create(conn, %{"prompt" => params}) do
    params = Map.put(params, "project_id", conn.assigns.project.id)

    case Projects.insert_prompt(params) do
      {:ok, prompt} ->
        conn
        |> put_flash(:info, "Prompt created.")
        |> redirect(to: prompt_path(conn, prompt))

      {:error, changeset} ->
        conn
        |> put_flash(:error, "Please see errors below.")
        |> render("new.html", changeset: changeset)
    end
  end

  def edit(conn, _params) do
    changeset = Projects.prompt_changeset(conn.assigns.prompt)
    render conn, "edit.html", changeset: changeset
  end

  def update(conn, %{"prompt" => prompt_params}) do
    # TODO: Ideally use another changeset(?) so the user can't change project_id.
    case Projects.update_prompt(conn.assigns.prompt, prompt_params) do
      {:ok, prompt} ->
        conn
        |> put_flash(:info, "Prompt updated.")
        |> redirect(to: prompt_path(conn, prompt))

      {:error, changeset} ->
        conn
        |> put_flash(:error, "Please see errors below.")
        |> render("edit.html", changeset: changeset)
    end
  end

  def delete(conn, _params) do
    Projects.delete_prompt!(conn.assigns.prompt)

    conn
    |> put_flash(:info, "Prompt deleted.")
    |> redirect(to: project_path(conn))
  end

  #
  # Helpers
  #

  defp rename_prompt_uuid(conn, _) do
    Map.put_in(conn, [:params, "prompt_uuid"], conn.params["uuid"])
  end

  defp project_path(conn) do
    Routes.manage_project_path(conn, :show, conn.assigns.project)
  end

  defp prompt_path(conn, prompt) do
    Routes.manage_project_prompt_path(conn, :show, conn.assigns.project, prompt)
  end
end
