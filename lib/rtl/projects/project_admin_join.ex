defmodule RTL.Projects.ProjectAdminJoin do
  use Ecto.Schema
  import Ecto.Changeset

  schema "project_admin_joins" do
    belongs_to :project, RTL.Projects.Project
    belongs_to :admin, RTL.Accounts. User
    timestamps()
  end

  def changeset(struct, params) do
    struct
    |> cast(params, [:project_id, :admin_id])
    |> validate_required([:project_id, :admin_id])
  end
end
