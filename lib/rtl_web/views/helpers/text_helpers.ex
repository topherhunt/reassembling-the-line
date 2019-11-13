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
    defaults = RTL.Projects.ProjectSetting.defaults()
    known_fields = Map.keys(defaults)
    unless field in known_fields, do: raise "Unknown ProjectSetting field: #{field}"
    default = defaults[field]

    (project.settings || %{})[field] || default
  end

  def icon(icon, extra_html \\ "") do
    raw("<i class='icon'>#{icon}</i>#{extra_html}")
  end
end
