defmodule RTLWeb.Admin.PromptController do
  use RTLWeb, :controller
  alias RTL.Projects

  plug :load_project
  plug :ensure_can_manage_project
  plug :load_prompt when action in [:show, :edit, :update, :delete]

  def new(conn, _params) do
    changeset = Projects.new_prompt_changeset()
    render conn, "new.html", changeset: changeset
  end

  def create(conn, %{"prompt" => params}) do
    params = Map.put(params, "project_id", conn.assigns.project.id)

    case Projects.insert_prompt(params) do
      {:ok, _prompt} ->
        conn
        |> put_flash(:info, "Question created.")
        |> redirect(to: Routes.admin_project_path(conn, :show, conn.assigns.project))

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
      {:ok, _prompt} ->
        conn
        |> put_flash(:info, "Question updated.")
        |> redirect(to: Routes.admin_project_path(conn, :show, conn.assigns.project))

      {:error, changeset} ->
        conn
        |> put_flash(:error, "Please see errors below.")
        |> render("edit.html", changeset: changeset)
    end
  end

  def delete(conn, _params) do
    Projects.delete_prompt!(conn.assigns.prompt)

    conn
    |> put_flash(:info, "Question deleted.")
    |> redirect(to: Routes.admin_project_path(conn, :show, conn.assigns.project))
  end
end
