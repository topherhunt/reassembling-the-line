defmodule EducateYour.ModelHelpers do
  alias EducateYour.{Repo, User, Video, Coding, Tagging, Tag}

  def empty_database do
    # Clean out cruft records possibly left over by earlier (crashed) tests...?
    Repo.delete_all(User)
    Repo.delete_all(Video)
    Repo.delete_all(Coding)
    Repo.delete_all(Tagging)
    Repo.delete_all(Tag)
  end
end
