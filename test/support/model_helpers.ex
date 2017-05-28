defmodule EducateYour.ModelHelpers do
  def empty_database do
    # Clean out cruft records possibly left over by earlier (crashed) tests...?
    EducateYour.Repo.delete_all(EducateYour.Question)
    EducateYour.Repo.delete_all(EducateYour.User)
    EducateYour.Repo.delete_all(EducateYour.Interview)
    EducateYour.Repo.delete_all(EducateYour.Vote)
    EducateYour.Repo.delete_all(EducateYour.Tag)
    EducateYour.Repo.delete_all(EducateYour.ScheduledTask)
    EducateYour.Repo.delete_all(EducateYour.ContactRequest)
  end
end
