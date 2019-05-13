defmodule ProjectSetting do
  # Defines the list of valid config fields.
  # Each field can be of type:
  #   * string
  #   * html
  #   * bool
  def valid_fields do
    %{
      # TODO: Eventually the logo should be an attached / uploaded file
      "logo_url" => :string,
      "intro_page" => :html,
      "thank_you_page" => :html,
      "show_explore_link" => :bool
    }
  end

  def default(_, "logo_url"), do: nil

  def default(project, "intro_page") do
    "
    <h1>Project: #{project.name}</h1>
    <p>Welcome! Feel free to take a look around.</p>
    "
  end

  def default(_, "thank_you_page") do
    "
    <h1>Thank you</h1>
    <p>Thank you for taking the time to share your experience! I hope you found it rewarding. And we'll do our best to enable your voice to inspire change on issues that matter to you.</p>
    <p>We're currently collecting data for the <strong>Thrive in Northern Netherlands</strong> project. As soon as the results are ready to share, we'll announce it on our mailing list.</p>
    <p class=\"text-center\">
      <a href=\"https://www.northernnetherlands.life/subscribe\" class=\"btn btn-primary\">
        Join our newsletter to get updates on this project
      </a>
    </p>
    <p class=\"text-center\">
      <a href=\"https://docs.google.com/forms/d/e/1FAIpQLScFmkgOIWIN3QKIT1TI6e2A440ixtfMsAQ04kVoh85TLDmbXw/viewform?usp=sf_link\" target=\"_blank\">Contact us with any questions</a>
    </p>
    "
  end

  def default(_, "show_explore_link"), do: "true"
end
