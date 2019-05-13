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
    if field in Map.keys(project.settings || %{}) do
      project.settings[field]
    else
      ProjectSetting.default(project, field)
    end
  end
end
