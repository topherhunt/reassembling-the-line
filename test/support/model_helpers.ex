defmodule Zb.ModelHelpers do
  def empty_database do
    # Clean out cruft records possibly left over by earlier (crashed) tests...?
    Zb.Repo.delete_all(Zb.Question)
    Zb.Repo.delete_all(Zb.User)
    Zb.Repo.delete_all(Zb.Interview)
    Zb.Repo.delete_all(Zb.Vote)
    Zb.Repo.delete_all(Zb.Tag)
    Zb.Repo.delete_all(Zb.ScheduledTask)
    Zb.Repo.delete_all(Zb.ContactRequest)
  end
end
