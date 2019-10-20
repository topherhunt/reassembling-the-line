defmodule RTLWeb.CustomBlockHelpers do
  use Phoenix.HTML
  alias RTLWeb.Router.Helpers, as: Routes

  def custom_block(conn, label) do
    project = conn.assigns[:project]
    all_labels = RTL.Projects.CustomBlock.templates() |> Enum.map(& &1.label)
    unless label in all_labels, do: raise "Unknown block label: #{inspect(label)}"

    if block = find_block(project, label) do
      block.body |> inject_variables(project) |> raw()
    else
      default_block(conn, label)
    end
  end

  defp find_block(nil, _label), do: nil
  defp find_block(proj, label), do: Enum.find(proj.custom_blocks, & &1.label == label)

  # We support certain variables for custom blocks.
  defp inject_variables(body, project) do
    body =
      if String.contains?(body, "{ADMIN_LOGIN_URL}") do
        user = RTL.Accounts.get_user_by!(admin_on_project: project)
        token = RTL.Accounts.get_login_token(user.email)
        url = Routes.auth_url(RTLWeb.Endpoint, :confirm, token: token)
        String.replace(body, "{ADMIN_LOGIN_URL}", url)
      else
        body
      end

    body
  end

  # Some default blocks inject fields on the assigned project.
  # Note: For some blocks, project may be nil.
  def default_block(conn, label) do
    project = conn.assigns[:project]
    RTLWeb.Manage.CustomBlockView.render("_#{label}.html", conn: conn, project: project)
  end
end
