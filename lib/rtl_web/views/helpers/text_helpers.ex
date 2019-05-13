defmodule RTLWeb.TextHelpers do
  use Phoenix.HTML

  def ellipsis(text, length) do
    if String.length(text) > length - 3 do
      String.slice(text, 0..length) <> "..."
    else
      text
    end
  end

  def project_setting(project, field) do
    unless field in Map.keys(ProjectSetting.valid_fields()) do
      raise "Unknown ProjectSetting field: #{field}"
    end

    (project.settings || %{})[field]
    # We don't fall back to a default value, the calling code can have default logic.
  end
end
