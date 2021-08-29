# I was using ExMachina but found these hand-rolled factories simple to set up
# and more transparent vis-a-vis Ecto association handling.
defmodule RTL.Factory do
  alias RTL.Repo
  alias RTL.Helpers, as: H
  alias RTL.{Accounts, Projects, Videos}
  alias RTL.Accounts.User
  alias RTL.Videos.{Video, Coding, Tagging, Tag}
  alias RTL.Projects.{Project, Prompt, ProjectAdminJoin, CustomBlock}

  def insert_user(params \\ %{}) do
    params = cast(params, [:name, :email, :confirmed_at])
    uuid = random_uuid()

    Accounts.insert_user!(%{
      name: params[:name] || "User #{uuid}",
      email: (params[:email] || "user_#{uuid}@example.com") |> String.downcase(),
      password: "password",
      confirmed_at: Map.get(params, :confirmed_at, H.now())
    }, :admin)
  end

  def insert_login_try(params \\ %{}) do
    params = cast(params, [:email])
    Accounts.insert_login_try!(params[:email])
  end

  def insert_project(params \\ %{}) do
    params = cast(params, [:name, :uuid, :admins])

    project = Projects.insert_project!(%{
      name: params[:name] || "Project #{random_uuid()}",
      uuid: params[:uuid] || random_uuid()
    })

    for admin <- params[:admins] || [] do
      Projects.add_project_admin!(admin, project)
    end

    project
  end

  def insert_prompt(params \\ %{}) do
    params = cast(params, [:project_id, :html])

    Projects.insert_prompt!(%{
      project_id: params[:project_id] || insert_project().id,
      html: params[:html] || "Prompt #{random_uuid()}"
    })
  end

  def insert_video(params \\ %{}) do
    params = cast(params, [
      :prompt_id,
      :title,
      :recording_filename,
      :thumbnail_filename,
      :project_id, # indirect
      :coded_with_tags # indirect
    ])

    hex = random_uuid()

    prompt_id =
      params[:prompt_id] ||
      insert_prompt(project_id: params[:project_id]).id

    video = Videos.insert_video!(%{
      prompt_id: prompt_id,
      speaker_name: "Speaker #{hex}",
      permission_show_name: true,
      recording_filename: params[:recording_filename] || "#{hex}.webm",
      thumbnail_filename: params[:thumbnail_filename] || "#{hex}.jpg"
    }, :generic)

    if tags = params[:coded_with_tags] do
      insert_coding(video_id: video.id, tags: tags)
    end

    video
  end

  def insert_coding(params \\ %{}) do
    params = cast(params, [:video_id, :coder_id, :completed_at, :tags])
    # :tags should be a list of 3-value tuples: [{name, starts_at, ends_at}, ...]

    video_id = params[:video_id] || insert_video().id
    project_id = Videos.get_video!(video_id, preload: :prompt).prompt.project_id
    tags = params[:tags] || []

    coding = Videos.insert_coding!(%{
      video_id: video_id,
      coder_id: params[:coder_id] || insert_user().id,
      completed_at: Map.get(params, :completed_at, Timex.now())
    })

    # Ensure each tag exists, and load it
    Enum.each(tags, fn({name, starts_at, ends_at}) ->
      tag_params = [project_id: project_id, name: name]
      tag = Videos.get_tag_by(tag_params) || insert_tag(tag_params)
      insert_tagging(%{
        coding: coding,
        tag: tag,
        starts_at: starts_at,
        ends_at: ends_at
      })
    end)

    coding
  end

  def insert_tagging(params \\ %{}) do
    params = cast(params, [:coding_id, :tag_id, :starts_at, :ends_at, :coding, :tag])

    Videos.insert_tagging!(%{
      coding_id: params[:coding_id] || H.try(params[:coding], :id) || insert_coding().id,
      tag_id: params[:tag_id] || H.try(params[:tag], :id) || raise("tag is required"),
      starts_at: params[:starts_at],
      ends_at: params[:ends_at]
    })
  end

  def insert_tag(params \\ %{}) do
    params = cast(params, [:project_id, :name, :color, :project])

    Videos.insert_tag!(%{
      project_id: params[:project_id] || H.try(params[:project], :id) || raise("project is required"),
      name: params[:name] || "Tag #{random_uuid()}",
      color: params[:color] || Videos.Tag.random_color()
    })
  end

  def random_uuid, do: Nanoid.generate(8)

  def empty_database do
    Repo.delete_all(User)
    Repo.delete_all(Video)
    Repo.delete_all(Coding)
    Repo.delete_all(Tagging)
    Repo.delete_all(Tag)
    Repo.delete_all(Project)
    Repo.delete_all(Prompt)
    Repo.delete_all(ProjectAdminJoin)
    Repo.delete_all(CustomBlock)
  end

  #
  # Internal
  #

  defp cast(params, allowed_keys) do
    params = Enum.into(params, %{})
    unexpected_key = Map.keys(params) |> Enum.find(& &1 not in allowed_keys)
    if unexpected_key, do: raise "Unexpected key: #{inspect(unexpected_key)}."
    params
  end
end
