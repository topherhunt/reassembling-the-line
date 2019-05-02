# Projects context
defmodule RTL.Projects do
  import Ecto.Query, warn: false
  alias RTL.Repo
  alias RTL.Projects.{Project, Prompt, ProjectAdminJoin}

  #
  # Project schema
  #

  def get_project(id, filt \\ []), do: get_project_by(Keyword.merge([id: id], filt))

  def get_project!(id, filt \\ []), do: get_project_by!(Keyword.merge([id: id], filt))

  def get_project_by(filt), do: Project |> Project.filter(filt) |> Repo.first()

  def get_project_by!(filt), do: Project |> Project.filter(filt) |> Repo.first!()

  def get_projects(filt \\ []), do: Project |> Project.filter(filt) |> Repo.all()

  def count_projects(filt \\ []), do: Project |> Project.filter(filt) |> Repo.count()

  def insert_project(params), do: new_project_changeset(params) |> Repo.insert()

  def insert_project!(params), do: new_project_changeset(params) |> Repo.insert!()

  def update_project(p, params), do: project_changeset(p, params) |> Repo.update()

  def update_project!(p, params), do: project_changeset(p, params) |> Repo.update!()

  # TODO: Will this cascade deletion of all dependent resources?
  def delete_project!(project), do: Repo.delete!(project)

  def new_project_changeset(params \\ %{}), do: Project.changeset(%Project{}, params)

  def project_changeset(project, params \\ %{}), do: Project.changeset(project, params)

  #
  # Prompt schema
  #

  def get_prompt(id, filt \\ []), do: get_prompt_by(Keyword.merge([id: id], filt))

  def get_prompt!(id, filt \\ []), do: get_prompt_by!(Keyword.merge([id: id], filt))

  def get_prompt_by(filt), do: Prompt |> Prompt.filter(filt) |> Repo.first()

  def get_prompt_by!(filt), do: Prompt |> Prompt.filter(filt) |> Repo.first!()

  def get_prompts(filt \\ []), do: Prompt |> Prompt.filter(filt) |> Repo.all()

  def count_prompts(filt \\ []), do: Prompt |> Prompt.filter(filt) |> Repo.count()

  def insert_prompt(params), do: new_prompt_changeset(params) |> Repo.insert()

  def insert_prompt!(params), do: new_prompt_changeset(params) |> Repo.insert!()

  def update_prompt(p, params), do: prompt_changeset(p, params) |> Repo.update()

  def update_prompt!(p, params), do: prompt_changeset(p, params) |> Repo.update!()

  def delete_prompt!(prompt), do: Repo.delete!(prompt)

  def new_prompt_changeset(params \\ %{}), do: Prompt.changeset(%Prompt{}, params)

  def prompt_changeset(prompt, params \\ %{}), do: Prompt.changeset(prompt, params)

  #
  # ProjectAdminJoin schema
  #

  def is_project_admin?(user, %Project{} = project) do
    from(j in ProjectAdminJoin, where: [project_id: ^project.id, admin_id: ^user.id])
    |> Repo.any?()
  end

  def add_project_admin!(user, %Project{} = project) do
    %ProjectAdminJoin{}
    |> ProjectAdminJoin.changeset(%{project_id: project.id, admin_id: user.id})
    |> Repo.insert!()
  end

  def remove_project_admin!(user, %Project{} = project) do
    from(j in ProjectAdminJoin, where: [project_id: ^project.id, admin_id: ^user.id])
    |> Repo.delete_all()
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
