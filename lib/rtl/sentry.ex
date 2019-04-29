defmodule RTL.Sentry do
  alias RTL.Helpers, as: H
  alias RTL.Projects

  def is_superadmin?(user) do
    superadmin_emails = H.env!("SUPERADMIN_EMAILS") |> String.split(" ")
    user.email in superadmin_emails
  end

  def can_manage_project?(user, project) do
    is_superadmin?(user) || Projects.is_project_admin?(project, user)
  end
end
