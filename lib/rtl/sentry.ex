defmodule RTL.Sentry do
  alias RTL.Helpers, as: H
  alias RTL.Projects

  def is_superadmin?(user) do
    superadmin_emails = H.env!("SUPERADMIN_EMAILS") |> String.split(" ")
    user.email in superadmin_emails
  end

  def can_view_project?(user, project) do
    is_superadmin?(user) || Projects.is_user_admin_of_project?(user, project)
  end
end
