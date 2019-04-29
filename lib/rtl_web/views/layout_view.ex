defmodule RTLWeb.LayoutView do
  use RTLWeb, :view

  import RTL.Sentry, only: [:can_manage_project?]
end
