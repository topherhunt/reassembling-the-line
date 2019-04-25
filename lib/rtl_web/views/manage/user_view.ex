defmodule RTLWeb.Manage.UserView do
  use RTLWeb, :view

  def id_and_label_for_projects(projects) do
    Enum.map(projects, fn(project) -> {"#{project.name}", project.id} end)
  end
end
