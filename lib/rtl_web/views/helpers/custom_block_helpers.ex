defmodule RTLWeb.CustomBlockHelpers do
  use Phoenix.HTML

  def custom_block(conn, label) do
    all_labels = RTL.Projects.CustomBlock.templates() |> Enum.map(& &1.label)
    unless label in all_labels, do: raise "Unknown block label: #{inspect(label)}"

    project = conn.assigns[:project]
    if block = find_block(project, label) do
      raw block.body
    else
      default_block(conn, label)
    end
  end

  defp find_block(nil, _label), do: nil
  defp find_block(proj, label), do: Enum.find(proj.custom_blocks, & &1.label == label)

  # Currently default blocks may inject data from the project record. In the future we
  # might add more advanced injection support.
  # Note: For some blocks, project may be nil.
  def default_block(conn, label) do
    project = conn.assigns[:project]
    RTLWeb.Manage.CustomBlockView.render("_#{label}.html", conn: conn, project: project)
  end
end
