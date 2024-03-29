# Populates the dev database with realistic testing data.
# To run it:
# > mix run scripts/seeds.exs

import RTL.Factory
alias RTL.Repo
alias RTL.Accounts.User
alias RTL.Projects.Project
alias RTL.Videos.{Video, Coding, Tagging, Tag}

RTL.Factory.empty_database()

admin = insert_user(name: "Admin", email: "admin@example.com")
coder = insert_user(name: "Coder", email: "coder@example.com")

project1 = insert_project(name: "Project 1", admins: [admin, coder])
tags = Enum.map(1..5, fn _ -> insert_tag(project: project1) end)

demo = insert_project(name: "Demo project", uuid: "demo", admins: [admin])
insert_prompt(project: demo, html: "This is a demo prompt. What do you think of US education?")
Enum.map(1..10, fn i -> insert_tag(project: demo, name: "Tag #{i}") end)

# A few sample videos with random taggings
Enum.each(1..5, fn _ ->
  video = insert_video()
  coding = insert_coding(video_id: video.id, coder_id: coder.id)
  Enum.take_random(tags, 2) |> Enum.each(fn(tag) ->
    insert_tagging(coding_id: coding.id, tag_id: tag.id)
  end)
end)

IO.puts "Seeding is complete!"
IO.puts "- #{Repo.count(User)} users"
IO.puts "- #{Repo.count(Project)} projects"
IO.puts "- #{Repo.count(Video)} videos"
IO.puts "- #{Repo.count(Coding)} codings"
IO.puts "- #{Repo.count(Tagging)} taggings"
IO.puts "- #{Repo.count(Tag)} tags"
IO.puts "\nYou can log in as:"
IO.puts "* UN #{admin.email} PW password"
IO.puts "* UN #{coder.email} PW password"
