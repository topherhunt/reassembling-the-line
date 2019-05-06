defmodule ProjectSetting do
  # Defines the list of valid config fields.
  # Each field can be of type:
  #   * string
  #   * html
  #   * bool ("1" or "0")
  def valid_fields do
    [
      # TODO: Eventually the logo should probably be an attached / uploaded file
      logo_url: :string,
      intro_page: :html,
      thank_you_page: :html
    ]
  end
end
