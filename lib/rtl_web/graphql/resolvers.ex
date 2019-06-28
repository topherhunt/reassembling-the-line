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
  # Tag
  #

  def get_tags(%Project{} = parent, _args, _resolution) do
    {:ok, Tag.all(project: parent)}
  end

  def get_tag_count_taggings(%Tag{} = parent, _args, _resolution) do
    {:ok, Tagging.count(tag: parent)}
  end
end
