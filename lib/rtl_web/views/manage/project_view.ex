defmodule RTLWeb.Manage.ProjectView do
  use RTLWeb, :view

  def id_and_label_for(users) do
    Enum.map(users, fn user -> {"#{user.full_name} (#{user.email})", user.id} end)
  end
end
