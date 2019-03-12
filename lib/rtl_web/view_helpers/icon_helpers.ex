defmodule RTLWeb.IconHelpers do
  use Phoenix.HTML

  def icon(type) do
    # Uses Ionicons. See https://ionicons.com/
    # and https://github.com/ionic-team/ionicons#using-the-font-icon
    raw("<i class=\"ion-md-#{type}\"></i>")
  end
end
