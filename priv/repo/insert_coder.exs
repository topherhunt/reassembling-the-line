# Usage:
# > mix run priv/repo/seed_coder.exs Whitney emailwhitney@gmail.com
# > mix run priv/repo/seeds.exs

alias EducateYourWeb.{Endpoint, Router}
alias EducateYour.Factory
alias EducateYour.Accounts

[name, email] = System.argv
coder = Factory.insert_user(%{full_name: name, email: email})
all_users = Accounts.get_all_users

IO.puts "Added coder \"#{coder.full_name}\"."
IO.puts "There are now #{length(all_users)} coders total."
IO.puts "Login paths:"
# TODO: How to run one mix task from another mix task? (this is duplicate logic)
Enum.each(all_users, fn(user) ->
  path = Router.Helpers.session_path(Endpoint, :login_from_uuid, user.uuid)
  IO.puts "* #{user.full_name} logs in with: #{path}"
end)
