# NOTE: Best practice is to return an {:error, message} tuple if authorization fails.
# I'm throwing an exception instead for simplicity.
# Ideally the more complex resolvers would use a `with` statement.
defmodule RTLWeb.Graphql.Resolvers do
  # import Absinthe.Resolution.Helpers, only: [batch: 3]

  alias RTL.{Repo, Sentry, Accounts, Videos}
  alias RTL.Projects.{Project, Prompt}
  alias RTL.Videos.{Coding, Video, Tagging, Tag}

  #
  # User
  #

  def get_coder(%Coding{} = parent, _args, _resolution) do
    id = parent.coder_id
    {:ok, Accounts.get_user(id)} |> error_if_nil("Can't find coder #{id}")
  end

  #
  # Project
  #

  def get_project(%Prompt{} = parent, _args, _resolution) do
    id = parent.project_id
    {:ok, Project.get(id)} |> error_if_nil("Can't find project #{id}")
  end

  #
  # Prompt
  #

  def get_prompt(%Video{} = parent, _args, _resolution) do
    id = parent.prompt_id
    {:ok, Prompt.get(id)} |> error_if_nil("Can't find prompt #{id}")
  end

  def get_prompt_sanitized_text(%Prompt{} = parent, _args, _resolution) do
    {:ok, HtmlSanitizeEx.strip_tags(parent.html)}
  end

  #
  # Video
  #

  def get_video(%Coding{} = parent, _args, _resolution) do
    id = parent.video_id
    {:ok, Videos.get_video(id)} |> error_if_nil("Can't find video #{id}")
  end

  def get_video_thumbnail_url(%Video{} = parent, _args, _resolution) do
    {:ok, Videos.video_thumbnail_url(parent)}
  end

  def get_video_recording_url(%Video{} = parent, _args, _resolution) do
    {:ok, Videos.video_recording_url(parent)}
  end

  #
  # Coding
  #

  def get_coding(_parent, %{id: id}, resolution) do
    # Ideally we'd use a `with` to chain these data loads and authorizations.
    coding = Videos.get_coding!(id, preload: [video: :prompt])
    project_id = coding.video.prompt.project_id
    assert_authorized(resolution, :project_id, project_id)

    {:ok, coding}
  end

  #
  # Taggings
  #

  def get_taggings(%Coding{} = parent, _args, _resolution) do
    {:ok, Tagging.all(coding: parent, order: :starts_at)}
  end

  def create_tagging(_parent, args, resolution) do
    params = Map.take(args, [:coding_id, :tag_id, :starts_at, :ends_at])
    tag = Tag.get!(args.tag_id, preload: :project)
    assert_authorized(resolution, :project_id, tag.project_id)

    {:ok, Tagging.insert!(params)}
  end

  def update_tagging(_parent, args, resolution) do
    params = Map.take(args, [:starts_at, :ends_at])
    tagging = Videos.Tagging.get!(args.id, preload: :tag)
    assert_authorized(resolution, :project_id, tagging.tag.project_id)

    {:ok, Tagging.update!(tagging, params)}
  end

  def delete_tagging(_parent, args, resolution) do
    tagging = Videos.Tagging.get!(args.id, preload: :tag)
    assert_authorized(resolution, :project_id, tagging.tag.project_id)

    {:ok, Tagging.delete!(tagging)}
  end

  #
  # Tag
  #

  def get_tag(%Tagging{} = parent, _args, _resolution) do
    id = parent.tag_id
    {:ok, Tag.get(id)} |> error_if_nil("Can't find tag #{id}")
  end

  def get_tags(%Project{} = parent, _args, _resolution) do
    {:ok, Tag.all(project: parent, order: :name)}
  end

  def get_tag_count_taggings(%Tag{} = parent, _args, _resolution) do
    {:ok, Tagging.count(tag: parent)}
  end

  def create_tag(_parent, args, resolution) do
    params = Map.take(args, [:project_id, :name])
    assert_authorized(resolution, :project_id, args.project_id)

    case Videos.insert_tag(params) do
      {:ok, tag} -> {:ok, tag}
      {:error, changeset} -> {:error, Repo.describe_errors(changeset)}
    end
  end

  def update_tag(_parent, args, resolution) do
    tag = Tag.get!(args.id)
    params = Map.take(args, [:name, :color])
    assert_authorized(resolution, :project_id, tag.project_id)

    {:ok, Tag.update!(tag, params)}
  end

  def delete_tag(_parent, args, resolution) do
    tag = Tag.get!(args.id)
    assert_authorized(resolution, :project_id, tag.project_id)

    {:ok, Tag.delete!(tag)}
  end

  #
  # Internal helpers
  #

  defp error_if_nil({:ok, nil}, error_message), do: {:error, error_message}
  defp error_if_nil({:ok, obj}, _error_message), do: {:ok, obj}

  def assert_authorized(resolution, :project_id, project_id) do
    current_user = resolution.context.current_user

    unless Sentry.can_manage_project?(current_user, %Project{id: project_id}) do
      raise "User #{current_user.id} is not authorized to manage project #{project_id}."
    end
  end
end
