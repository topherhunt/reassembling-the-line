defmodule RTLWeb.CustomBlockHelpers do
  use Phoenix.HTML

  def custom_block(conn, label) do
    unless label in RTL.Projects.CustomBlock.templates() |> Enum.map(& &1.label) do
      raise "Unknown block label: #{inspect(label)}"
    end

    project = conn.assigns[:project]
    if block = find_block(project, label) do
      raw block.body
    else
      default_block(project, label)
    end
  end

  defp find_block(nil, _label), do: nil
  defp find_block(proj, label), do: Enum.find(proj.custom_blocks, & &1.label == label)

  # Currently default blocks may inject data from the project record. In the future we
  # might add more advanced injection support.
  # Note: For some blocks, project may be nil.
  def default_block(conn, label) do
    RTLWeb.Manage.CustomBlockView.render(conn, "_#{label}.html")
  end

  # TODO: Remove this commented-out stuff once I confirm that the custom block default
  # partials are working as expected.

  # def default_block(_project, "navbar_logo") do
  #   ~E"""
  #     <%= link icon("video_library", " Reassembling the Line"),
  #       to: Routes.home_path(@conn, :index),
  #       class: "navbar-brand text-info" %>
  #   """
  # end

  # def default_block(_project, "footer") do
  #   ~E"""
  #     <div class="text-center small">
  #       <strong><%= link "Reassembling the Line", to: "/" %></strong>
  #       &nbsp; &nbsp;
  #       <%= link "Your data", to: Routes.home_path(@conn, :your_data), target: "_blank" %>
  #       &nbsp; &nbsp;
  #       <%= link "Contact us", to: contact_us_url(), target: "_blank" %>
  #     </div>
  #   """
  # end

  # def default_block(project, "landing_page") do
  #   owner = Accounts.get_user_by!(admin_on_project: project)
  #   ~E"""
  #     <h1><%= project.name %></h1>
  #     <p>This project is run by <a href="mailto:<%= owner.email %>"><%= owner.full_name %></a> using the <%= link "RTL", to: "/" %> platform.</p>
  #   """
  # end

  # def default_block(_project, "recording_page_intro") do
  #   ~E"""
  #     <h1>Share your story</h1>
  #     <p>Thank you for taking the time to share your experience! We hope you find it rewarding. And we'll do our best to enable your voice to inspire change on issues that matter to you.</p>
  #   """
  # end

  # def default_block(project, "recording_page_consent_text") do
  #   ~E"""
  #     By clicking the button below, you're giving consent for Reassembling the Line to store your data as part of this project, <%= link project.name, to: Routes.explore_project_path(@conn, :show, project), target: "_blank" %>. See our <%= link "data policy", to: Routes.home_path(@conn, :your_data), target: "_blank" %> for more information.
  #   """
  # end

  # def default_block(project, "thank_you_page") do
  #   ~E"""
  #     <h1>🎉 Thank you 🎉</h1>

  #     <p>Thank you for taking the time to share your story as part of the <strong><%= project.name %></strong> project. To learn more about the project, or to reach the project owner, click the link below.</p>

  #     <p class="text-center"><%= link "About this project", to: Routes.explore_project_path(@conn, :show, project) %></p>
  #   """
  # end
end
