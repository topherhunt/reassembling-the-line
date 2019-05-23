defmodule RTLWeb.Share.FromWebcamView do
  use RTLWeb, :view

  def permission_options(project) do
    settings_json =
      project_setting(project, "recording_permission_options") ||
      default_recording_permission_options()

    Jason.decode!(settings_json)
  end

  def default_recording_permission_options do
    ~s({
      "I give permission to share this recording with <strong>everyone</strong>.": "public",
      "I give permission to share this recording with <strong>researchers on this project, but no one else</strong>.": "researchers"
    })
  end
end
