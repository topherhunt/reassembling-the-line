# Script for populating the database. You can run it as:
# > mix run priv/repo/seeds.exs

alias RTLWeb.Endpoint
alias RTLWeb.Router.Helpers, as: Routes
alias RTL.Factory
alias RTL.Repo
alias RTL.Accounts
alias RTL.Videos
alias RTL.Accounts.User
alias RTL.Videos.{Video, Coding, Tagging, Tag}

defmodule Helpers do
  def in_days(n) do
    Timex.today |> Timex.shift(days: n)
  end
end

Accounts.delete_all_users
Videos.delete_all_content

_whitney = Factory.insert_user(full_name: "Whitney", email: "emailwhitney@gmail.com")
coder    = Factory.insert_user(full_name: "Coder")

tags = (1..5) |> Enum.map(fn(_) -> Factory.insert_tag end)

# A few sample videos with random taggings
(1..5) |> Enum.each(fn(_index) ->
  video = Factory.insert_video
  coding = Factory.insert_coding(video_id: video.id, coder_id: coder.id)
  Enum.take_random(tags, 2) |> Enum.each(fn(tag) ->
    Factory.insert_tagging(coding_id: coding.id, tag_id: tag.id)
  end)
end)

IO.puts "Seeding is complete!"
IO.puts "- #{Repo.count(User)} users"
IO.puts "- #{Repo.count(Video)} videos"
IO.puts "- #{Repo.count(Coding)} codings"
IO.puts "- #{Repo.count(Tagging)} Taggings"
IO.puts "- #{Repo.count(Tag)} tags"

# TODO: Is it possible to invoke a second mix task from a first?
IO.puts "Login paths:"
Enum.each(Accounts.get_users, fn(user) ->
  path = Routes.auth_path(Endpoint, :login_from_uuid, user.uuid)
  IO.puts "* #{user.full_name} logs in with: #{path}"
end)
