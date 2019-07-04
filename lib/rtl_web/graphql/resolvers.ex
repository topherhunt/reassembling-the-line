defmodule RTLWeb.Graphql.Resolvers do
  # import Absinthe.Resolution.Helpers, only: [batch: 3]
  alias RTL.Videos
  alias RTL.Projects.{Project, Prompt}
  alias RTL.Videos.{Coding, Video, Tagging, Tag}

  #
  # User
  #

  def get_coder(%Coding{} = parent, _args, _resolution) do
    {:ok, Prompt.get!(parent.coder_id)}
  end

  #
  # Project
  #

  def get_project(%Prompt{} = parent, _args, _resolution) do
    {:ok, Project.get!(parent.project_id)}
  end

  #
  # Prompt
  #

  def get_prompt(%Video{} = parent, _args, _resolution) do
    {:ok, Prompt.get!(parent.prompt_id)}
  end

  def get_prompt_sanitized_text(%Prompt{} = parent, _args, _resolution) do
    {:ok, HtmlSanitizeEx.strip_tags(parent.html)}
  end

  #
  # Video
  #

  def get_video(%Coding{} = parent, _args, _resolution) do
    {:ok, Video.get!(parent.video_id)}
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
    {:ok, Coding.get!(id)}
  end

  #
  # Taggings
  #

  def get_taggings(%Coding{} = parent, _args, _resolution) do
    {:ok, Tagging.all(coding: parent)}
  end

  def create_tagging(_parent, args, _resolution) do
    # TODO: Authorize that the user is admin on this project
    params = Map.take(args, [:coding_id, :tag_id, :starts_at, :ends_at])
    tagging = Tagging.insert!(params)
    {:ok, tagging}
  end

  def update_tagging(_parent, args, _resolution) do
    params = Map.take(args, [:starts_at, :ends_at])
    tagging = Tagging.get!(id: args.id) |> Tagging.update!(params)
    {:ok, tagging}
  end

  def delete_tagging(_parent, args, _resolution) do
    tagging = Tagging.get!(id: args.id) |> Tagging.delete!()
    {:ok, tagging}
  end

  #
  # Tag
  #

  def get_tag(%Tagging{} = parent, _args, _resolution) do
    {:ok, Tag.get!(parent.tag_id)}
  end

  def get_tags(%Project{} = parent, _args, _resolution) do
    {:ok, Tag.all(project: parent, order: :text)}
  end

  def get_tag_count_taggings(%Tag{} = parent, _args, _resolution) do
    {:ok, Tagging.count(tag: parent)}
  end

  def create_tag(_parent, args, _resolution) do
    IO.inspect(args, label: "args")
    # TODO: Authorize that the user is admin on this project
    params = Map.take(args, [:project_id, :text])
    # TODO: Consider moving this generated data down to the changeset
    params = Map.put(params, :color, Tag.random_color())
    tag = Tag.insert!(params)
    {:ok, tag}
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
end
