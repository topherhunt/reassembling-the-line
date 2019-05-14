defmodule ProjectSetting do
  # Defines the list of valid config fields.
  # TODO: The field types don't matter. Make everything a string, and instead define brief custom description / explanation of each field and how to use it.
  def valid_fields do
    %{
      "navbar_logo" => :html,
      "intro_page" => :html,
      "thank_you_page" => :html,
      "show_explore_link" => :bool
    }
  end
end
