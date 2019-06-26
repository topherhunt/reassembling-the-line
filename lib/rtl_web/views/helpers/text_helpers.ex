defmodule RTLWeb.TextHelpers do
  use Phoenix.HTML

  def ellipsis(text, length) do
    cond do
      text == nil ->
        nil
      String.length(text) > length - 3 ->
        String.slice(text, 0..length) <> "..."
      true ->
        text
    end
  end

  def project_setting(project, field) do
    unless field in Map.keys(RTL.Projects.ProjectSetting.valid_fields()) do
      raise "Unknown ProjectSetting field: #{field}"
    end

    (project.settings || %{})[field]
    # We don't fall back to a default value, the calling code can have default logic.
  end

  def icon(icon, extra_html \\ "") do
    raw("<i class='icon'>#{icon}</i>#{extra_html}")
  end
end
