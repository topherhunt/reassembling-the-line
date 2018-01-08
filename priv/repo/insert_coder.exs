# Usage:
# > mix run priv/repo/seed_coder.exs Whitney emailwhitney@gmail.com
# > mix run priv/repo/seeds.exs

import EducateYour.Factory
alias EducateYour.{Endpoint, Router, Repo, User}

[name, email] = System.argv()

coder = insert :user, full_name: name, email: email

IO.puts "Added #{coder.full_name}"
IO.puts "There are now #{Repo.count(User)} coders total."
IO.puts "Login paths:"
Repo.all(User) |> Enum.each(fn(user) ->
  path = Router.Helpers.session_path(Endpoint, :login_from_uuid, user.uuid)
  IO.puts "* #{user.full_name} logs in with: #{path}"
end)
