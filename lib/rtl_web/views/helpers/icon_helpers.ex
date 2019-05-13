defmodule RTLWeb.IconHelpers do
  use Phoenix.HTML

  # TODO: Replace all uses of this with the Material Design icons.
  def icon(icon) do
    # Uses Ionicons. See https://ionicons.com/
    # and https://github.com/ionic-team/ionicons#using-the-font-icon
    raw("<i class=\"ion-md-#{icon}\"></i>")
  end

  def icon_and_text(icon, unsafe_text) do
    # Sanitize the accompanying text to protect against user data injection risk
    {:safe, safe_text} = html_escape(unsafe_text)
    raw("<i class=\"ion-md-#{icon}\"></i>&nbsp; #{safe_text}")
  end
end
