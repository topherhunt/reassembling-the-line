defmodule EducateYour.ModelHelpers do
  import EducateYour.Factory
  alias EducateYour.{Repo, User, Video, Coding, Tagging, Tag}

  def empty_database do
    # Clean out cruft records possibly left over by earlier (crashed) tests...?
    Repo.delete_all(User)
    Repo.delete_all(Video)
    Repo.delete_all(Coding)
    Repo.delete_all(Tagging)
    Repo.delete_all(Tag)
  end

  def insert_video_with_tags(tag_strings) do
    video = insert :video
    coding = insert :coding, video: video
    tags = tag_strings |> Enum.map(fn(string) ->
      case String.split(string, ":") do
        [context, text] ->
          %{"context" => context, "text" => text}
        [context, text, starts_at, ends_at] ->
          %{"context"=>context,"text"=>text,"starts_at"=>starts_at,"ends_at"=>ends_at}
      end
    end)
    Coding.associate_tags(coding, tags)
    video
  end
end
