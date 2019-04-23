# Projects context
defmodule RTL.Projects do
  import Ecto.Query, warn: false
  alias RTL.Repo
  alias RTL.Projects.{Project, ProjectAdminJoin}

  #
  # Project schema
  #

  def get_project(id, filters \\ []) do
    Keyword.merge([id: id], filters) |> first_project()
  end

  def get_project!(id, filters \\ []) do
    Keyword.merge([id: id], filters) |> first_project!()
  end

  def first_project(filters \\ []) do
    Project |> apply_filters(filters) |> Repo.first()
  end

  def first_project!(filters \\ []) do
    Project |> apply_filters(filters) |> Repo.first!()
  end

  def get_projects(filters \\ []) do
    Project |> apply_filters(filters) |> Repo.all()
  end

  defp apply_filters(starting_query, filters) do
    Enum.reduce(filters, starting_query, fn({k, v}, q) ->
      Project.filter_query(q, k, v)
    end)
  end

  def insert_project(params), do: new_project_changeset(params) |> Repo.insert()

  def insert_project!(params), do: new_project_changeset(params) |> Repo.insert!()

  def update_project(p, params), do: project_changeset(p, params) |> Repo.update()

  def update_project!(p, params), do: project_changeset(p, params) |> Repo.update!()

  # TODO: Will this cascade deletion of all dependent resources?
  def delete_project!(project), do: Repo.delete!(project)

  def new_project_changeset(params \\ %{}), do: Project.changeset(%Project{}, params)

  def project_changeset(proj, params \\ %{}), do: Project.changeset(proj, params)

  #
  # ProjectAdminJoin schema
  #

  def is_user_admin_of_project?(user, project) do
    from(j in ProjectAdminJoin, where: [project_id: ^project.id, admin_id: ^user.id])
    |> Repo.any?()
  end

  def insert_project_admin_join!(project, admin) do
    %ProjectAdminJoin{}
    |> ProjectAdminJoin.changeset(%{project_id: project.id, admin_id: admin.id})
    |> Repo.insert!()
  end

  #
  # Pubsub stuff
  #

  def subscribe_to_all_projects() do
    # RTL.Videos context will emit notifications whenever videos are changed.
    # Each notification consumer's handle_info will be called with that payload.
    # NOTE: This will be awkward to scale. How to trigger the proper notifications
    # & minimize unnucessary notifications when there's tons of different projects
    # and tons of connected admins, with overlapping access?
    # I suspect that would be easier to reason about if each project has an Owner
    # who is the primary person (and the projects are scoped under that user id)
    Phoenix.PubSub.subscribe(RTL.PubSub, "RTL.Projects.all_projects")
  end
end
