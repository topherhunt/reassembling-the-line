defmodule RTLWeb.Admin.ProjectView do
  use RTLWeb, :view

  def id_and_label_for(users) do
    Enum.map(users, fn user -> {"#{user.name} (#{user.email})", user.id} end)
  end
end
