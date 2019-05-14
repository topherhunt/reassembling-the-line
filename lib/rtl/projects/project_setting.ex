defmodule ProjectSetting do
  # Defines the list of valid config fields.
  # Each field can be of type:
  #   * string
  #   * html
  #   * bool
  def valid_fields do
    %{
      # TODO: Eventually the logo should be an attached / uploaded file
      "navbar_logo" => :string,
      "intro_page" => :html,
      "thank_you_page" => :html,
      "show_explore_link" => :bool
    }
  end
end
