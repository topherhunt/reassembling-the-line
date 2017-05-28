# Script for populating the database. You can run it as:
# > mix run priv/repo/seeds.exs

defmodule Helpers do
  def in_days(n) do
    Timex.today |> Timex.shift(days: n)
  end
end

import Zb.Factory
alias Zb.{Repo, User, Question, Interview, Vote, VoteTagging, Tag, ScheduledTask, ContactRequest}

Repo.delete_all(User)
Repo.delete_all(Question)
Repo.delete_all(Interview)
Repo.delete_all(Vote)
Repo.delete_all(VoteTagging)
Repo.delete_all(Tag)
Repo.delete_all(ScheduledTask)
Repo.delete_all(ContactRequest)

# Real questions
q1 = insert :question, position: 1, text: "What do you remember about your first ZB session?", eligible_for_voting: true
# (Only question 1 for beta testing)
# q2 = insert :question, position: 2, text: "In thinking about your own students, what are you most interested to find out about your peers' students?"
# q3 = insert :question, position: 3, text: "Describe someone you encountered recently who you thought would benefit from ZB. Why did you think they'd benefit from it? What did they do or say that made you believe that?", eligible_for_voting: true

# Users
# You can log in as admin like this: /sessions/login_from_uuid/abcdef123
admin = insert :user, type: "admin", full_name: "Whitney Admin", email: "emailwhitney+zb-admin@gmail.com", uuid: "abcdef123"
u1 = insert :user, type: "faculty", email: "emailwhitney+zb-faculty-1@gmail.com", full_name: "Whitney Faculty 1", min_votes_needed: 2
u2 = insert :user, type: "faculty", email: "emailwhitney+zb-faculty-2@gmail.com", full_name: "Whitney Faculty 2", min_votes_needed: 2
u3 = insert :user, type: "faculty", email: "emailwhitney+zb-faculty-3@gmail.com", full_name: "Whitney Faculty 3", min_votes_needed: 2
u4 = insert :user, type: "faculty", email: "hunt.topher+zb-faculty-4@gmail.com", full_name: "Topher Faculty 4", min_votes_needed: 2
u5 = insert :user, type: "faculty", email: "hunt.topher+zb-faculty-5@gmail.com", full_name: "Topher Faculty 5", min_votes_needed: 2

# All users have the same tasks
[u1, u2, u3, u4, u5] |> Enum.each(fn(user) ->
  insert :scheduled_task, user: user, command: "do_interview:1", due_on_date: Helpers.in_days(1)
  # insert :scheduled_task, user: user, command: "do_interview:2", due_on_date: Timex.today
  # insert :scheduled_task, user: user, command: "do_interview:3", due_on_date: Helpers.in_days(3)
  insert :scheduled_task, user: user, command: "meet_voting_quota", due_on_date: Helpers.in_days(3)
end)

# Add some stock recommended tags
t1 = insert :tag, text: "physical",  recommended: true
t2 = insert :tag, text: "mental",    recommended: true
t3 = insert :tag, text: "emotional", recommended: true
t4 = insert :tag, text: "spiritual", recommended: true

# Add some interviews that have been voted
# i1 = insert :interview, user: u1, question: q3, completed_at: Timex.now
# i2 = insert :interview, user: u2, question: q3, completed_at: Timex.now
# i3 = insert :interview, user: u3, question: q3, completed_at: Timex.now
# v1 = insert :vote, user: u2, interview: i1
# v2 = insert :vote, user: u1, interview: i2
# v3 = insert :vote, user: u3, interview: i1
# insert :vote_tagging, vote: v1, tag: t1
# insert :vote_tagging, vote: v1, tag: t2
# insert :vote_tagging, vote: v2, tag: t2
# insert :vote_tagging, vote: v2, tag: t4
# insert :vote_tagging, vote: v3, tag: t4

# Populate all other pending interviews for each faculty member
Zb.NewUserSetup.ensure_all_faculy_have_all_interviews

IO.puts "Seeding is complete!"
IO.puts "- #{Repo.count(User)} users"
IO.puts "- #{Repo.count(ScheduledTask)} scheduled tasks"
IO.puts "- #{Repo.count(Question)} questions"
IO.puts "- #{Repo.count(Interview)} interviews"
IO.puts "- #{Repo.count(Vote)} votes"
IO.puts "- #{Repo.count(VoteTagging)} VoteTaggings"
IO.puts "- #{Repo.count(Tag)} tags"
IO.puts "The admin user can log in via this path:"
IO.puts Zb.Router.Helpers.session_path(Zb.Endpoint, :login_from_uuid, admin.uuid)
