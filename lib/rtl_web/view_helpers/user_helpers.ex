defmodule RTLWeb.UserHelpers do
  use Phoenix.HTML

  def is_superadmin?(user) do
    RTL.Sentry.is_superadmin?(user)
  end
end
