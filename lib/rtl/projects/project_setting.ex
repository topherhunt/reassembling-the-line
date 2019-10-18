defmodule RTL.Projects.ProjectSetting do
  # Defines the list of valid config fields.
  # TODO: The field types don't matter. Make everything a string, and instead define brief custom description / explanation of each field and how to use it.
  def valid_fields do
    %{
      # TODO: I don't think we need these permission questions. Better for the consent screen to say, By submitting this video, you're giving permission for us to share your recording (and name, if provided) with [TARGET AUDIENCE] as part of [PROJECT]. You can contact us anytime if you have questions about this. (Meaning, we need to make sure this consent text never changes without careful thought.)
      # TODO: Check w WHT and CH before doing anything about this.
      "recording_permission_options" => "JSON for the webcam recording permission options. Must be an object where each key is the label display text and each value is the setting to store.",

      # This setting will likely stay, though it might be renamed.
      "show_explore_link" => "\"true\" if the link to explore project results should be visible in the navbar.",

      # Will be made redundant once we implement CustomBlocks
      "logo_image_url" => "URL for the logo that should be shown in the navbar next to the project name (if any).",
      "logo_link_url" => "Where should the user be directed when they click on the logo? (by default, the logo won't link anywhere)",
      "project_intro_page" => "Text / HTML for the project information page that any participant will see when they click on the project name / logo in the navbar.",
      "webcam_recording_intro" => "Text / HTML shown at the top of the webcam recording page, incl. the h1 title.",
      "recording_consent_text" => "Text / HTML for the webcam recording page consent box.",
      "thank_you_page" => "Text / HTML shown to the participant after they submit a recording."
    }
  end
end
