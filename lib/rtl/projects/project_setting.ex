defmodule RTL.Projects.ProjectSetting do
  # Defines the list of valid config fields.
  # TODO: The field types don't matter. Make everything a string, and instead define brief custom description / explanation of each field and how to use it.
  def valid_fields do
    %{
      # TODO: I don't think we need these permission questions. Better for the consent screen to say, By submitting this video, you're giving permission for us to share your recording (and name, if provided) with [TARGET AUDIENCE] as part of [PROJECT]. You can contact us anytime if you have questions about this. (Meaning, we need to make sure this consent text never changes without careful thought.)
      # TODO: Check w WHT and CH before doing anything about this.
      "recording_permission_options" => "JSON for the webcam recording permission options. Must be an object where each key is the label display text and each value is the setting to store.",

      # This setting will likely stay, though it might be renamed.
      "show_explore_link" => "\"true\" if the link to explore project results should be visible in the navbar."
    }
  end
end
