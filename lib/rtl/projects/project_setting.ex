defmodule RTL.Projects.ProjectSetting do
  # Defines the list of valid config fields.
  # TODO: The field types don't matter. Make everything a string, and instead define brief custom description / explanation of each field and how to use it.
  def valid_fields do
    %{
      "navbar_logo" => "Text / HTML for the logo section of the navbar (top-left)",
      "intro_page" => "Text / HTML for the project information page that any participant will see when they click on the project name / logo in the navbar",
      "thank_you_page" => "Text / HTML shown to the participant after they submit a recording",
      "show_explore_link" => "\"true\" if the link to explore project results should be visible in the navbar",
      "recording_permission_options" => "JSON for the webcam recording permission options. Must be an object where each key is the label display text and each value is the setting to store.",
      "recording_consent_text" => "Text / HTML for the webcam recording page consent box"
    }
  end
end
