defmodule RTLWeb.LayoutView do
  use RTLWeb, :view

  def is_superadmin?(user) do
    RTL.Sentry.is_superadmin?(user)
  end
end
