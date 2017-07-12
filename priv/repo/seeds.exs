# Script for populating the database. You can run it as:
# > mix run priv/repo/seeds.exs

defmodule Helpers do
  def in_days(n) do
    Timex.today |> Timex.shift(days: n)
  end
end

import EducateYour.Factory
alias EducateYour.{Endpoint, Router, Repo, User, Video, Coding, Tagging, Tag}

Repo.delete_all(User)
Repo.delete_all(Video)
Repo.delete_all(Coding)
Repo.delete_all(Tagging)
Repo.delete_all(Tag)

whitney = insert :user, full_name: "Whitney", email: "emailwhitney@gmail.com"
coder   = insert :user, full_name: "Coder"

tags = (1..5) |> Enum.map(fn(_index) ->
  insert :tag
end)

# A few sample videos with random taggings
(1..5) |> Enum.each(fn(_index) ->
  video = insert :video
  coding = insert :coding, updated_by_user: coder
  Enum.take_random(tags, 2) |> Enum.each(fn(tag) ->
    insert :tagging, coding: coding, tag: tag
  end)
end)

IO.puts "Seeding is complete!"
IO.puts "- #{Repo.count(User)} users"
IO.puts "- #{Repo.count(Video)} videos"
IO.puts "- #{Repo.count(Coding)} codings"
IO.puts "- #{Repo.count(Tagging)} Taggings"
IO.puts "- #{Repo.count(Tag)} tags"
IO.puts "Whitney's autologin link:"
IO.puts Router.Helpers.session_path(Endpoint, :login_from_uuid, whitney.uuid)
IO.puts "Coder's autologin link:"
IO.puts Router.Helpers.session_path(Endpoint, :login_from_uuid, coder.uuid)
