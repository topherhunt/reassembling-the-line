defmodule RTL.Sentry do
  alias RTL.Helpers, as: H
  alias RTL.Projects
  alias RTL.Accounts.User
  alias RTL.Projects.Project

  def is_superadmin?(nil), do: false

  def is_superadmin?(%User{} = user) do
    superadmin_emails = H.env!("SUPERADMIN_EMAILS") |> String.split(" ")
    user.email in superadmin_emails
  end

  def can_manage_project?(nil, _), do: false
  def can_manage_project?(_, nil), do: false
  def can_manage_project?(%User{} = user, %Project{} = project) do
    is_superadmin?(user) || Projects.is_project_admin?(user, project)
  end
end
