defmodule RTLWeb.Admin.CustomBlockController do
  use RTLWeb, :controller
  alias RTL.Repo
  alias RTL.Projects

  plug :load_project
  plug :ensure_superadmin

  def index(conn, _params) do
    templates = RTL.Projects.CustomBlock.templates()
    render conn, "index.html", templates: templates
  end

  def edit(conn, %{"label" => label}) do
    project = conn.assigns.project
    block = project.custom_blocks |> Enum.find(& &1.label == label)
    body = if block, do: block.body, else: nil
    render conn, "edit.html", label: label, body: body
  end

  def update(conn, %{"label" => label, "body" => body}) do
    project = conn.assigns.project
    block = project.custom_blocks |> Enum.find(& &1.label == label)

    if block do
      Projects.update_custom_block!(block, %{body: body})
    else
      Projects.insert_custom_block!(%{project_id: project.id, label: label, body: body})
    end

    conn
    |> put_flash(:info, "Saved.")
    |> redirect(to: Routes.admin_custom_block_path(conn, :index, project))
  end

  def delete(conn, %{"label" => label}) do
    project = conn.assigns.project
    block = project.custom_blocks |> Enum.find(& &1.label == label)

    if block, do: Projects.delete_custom_block!(block)

    conn
    |> put_flash(:info, "Reset to default.")
    |> redirect(to: Routes.admin_custom_block_path(conn, :index, project))
  end

  def export(conn, _params) do
    project = conn.assigns.project
    filename = "#{Date.utc_today}-rtl-project-#{project.id}-custom-blocks.json"

    data =
      project.custom_blocks
      |> Enum.map(& %{label: &1.label, body: &1.body})
      |> Jason.encode!()

    send_download conn, {:binary, data}, filename: filename
  end

  def import(conn, _params) do
    render conn, "import.html"
  end

  def import_submit(conn, %{"file" => %Plug.Upload{} = file}) do
    project = conn.assigns.project
    blocks = File.read!(file.path) |> Jason.decode!()

    Projects.query_custom_blocks(project: project) |> Repo.delete_all()

    {ct_inserted} =
      Enum.reduce(blocks, {0}, fn block_params, {count} ->
        block_params = Map.put(block_params, "project_id", project.id)
        Projects.insert_custom_block!(block_params)
        {count + 1}
      end)

    conn
    |> put_flash(:info, "Success. Imported #{ct_inserted} custom blocks into this project.")
    |> redirect(to: Routes.admin_custom_block_path(conn, :index, project))
  end
end
