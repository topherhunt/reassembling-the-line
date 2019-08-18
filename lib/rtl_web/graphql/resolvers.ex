defmodule RTLWeb.Graphql.Resolvers do
  # import Absinthe.Resolution.Helpers, only: [batch: 3]

  alias RTL.Repo
  alias RTL.Accounts
  alias RTL.Videos
  alias RTL.Projects.{Project, Prompt}
  alias RTL.Videos.{Coding, Video, Tagging, Tag}

  #
  # User
  #

  def get_coder(%Coding{} = parent, _args, _resolution) do
    id = parent.coder_id
    Accounts.get_user(id) |> getter_response_tuple("coder", id)
  end

  #
  # Project
  #

  def get_project(%Prompt{} = parent, _args, _resolution) do
    id = parent.project_id
    Project.get(id) |> getter_response_tuple("project", id)
  end

  #
  # Prompt
  #

  def get_prompt(%Video{} = parent, _args, _resolution) do
    id = parent.prompt_id
    Prompt.get(id) |> getter_response_tuple("prompt", id)
  end

  def get_prompt_sanitized_text(%Prompt{} = parent, _args, _resolution) do
    {:ok, HtmlSanitizeEx.strip_tags(parent.html)}
  end

  #
  # Video
  #

  def get_video(%Coding{} = parent, _args, _resolution) do
    id = parent.video_id
    Videos.get_video(id) |> getter_response_tuple("video", id)
  end

  def get_video_thumbnail_url(%Video{} = parent, _args, _resolution) do
    {:ok, Videos.thumbnail_url(parent)}
  end

  def get_video_recording_url(%Video{} = parent, _args, _resolution) do
    {:ok, Videos.recording_url(parent)}
  end

  #
  # Coding
  #

  def get_coding(_parent, %{id: id}, _resolution) do
    Videos.get_coding(id) |> getter_response_tuple("coding", id)
  end

  #
  # Taggings
  #

  def get_taggings(%Coding{} = parent, _args, _resolution) do
    {:ok, Tagging.all(coding: parent, order: :starts_at)}
  end

  def create_tagging(_parent, args, _resolution) do
    # TODO: Authorize that the user is admin on this project
    params = Map.take(args, [:coding_id, :tag_id, :starts_at, :ends_at])
    tagging = Tagging.insert!(params)
    {:ok, tagging}
  end

  def update_tagging(_parent, args, _resolution) do
    params = Map.take(args, [:starts_at, :ends_at])
    tagging = Tagging.get!(args.id) |> Tagging.update!(params)
    {:ok, tagging}
  end

  def delete_tagging(_parent, args, _resolution) do
    tagging = Tagging.get!(args.id) |> Tagging.delete!()
    {:ok, tagging}
  end

  #
  # Tag
  #

  def get_tag(%Tagging{} = parent, _args, _resolution) do
    id = parent.tag_id
    Tag.get(id) |> getter_response_tuple("tag", id)
  end

  def get_tags(%Project{} = parent, _args, _resolution) do
    {:ok, Tag.all(project: parent, order: :text)}
  end

  def get_tag_count_taggings(%Tag{} = parent, _args, _resolution) do
    {:ok, Tagging.count(tag: parent)}
  end

  def create_tag(_parent, args, _resolution) do
    # TODO: Authorize that the user is admin on this project
    params = Map.take(args, [:project_id, :text])

    case Videos.insert_tag(params) do
      {:ok, tag} -> {:ok, tag}
      {:error, changeset} -> {:error, Repo.describe_errors(changeset)}
    end
  end

  def update_tag(_parent, args, _resolution) do
    # TODO: Authorize that the user is admin on this project
    params = Map.take(args, [:text, :color])
    tag = Tag.get!(args.id) |> Tag.update!(params)
    {:ok, tag}
  end

  def delete_tag(_parent, args, _resolution) do
    # TODO: Authorize that the user is admin on this project
    tag = Tag.get!(args.id) |> Tag.delete!()
    {:ok, tag}
  end

  #
  # Internal helpers
  #

  defp getter_response_tuple(result, label, id) do
    case result do
      nil -> {:error, "Can't find #{label} #{id}"}
      object -> {:ok, object}
    end
  end
end
