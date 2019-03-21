# Usage:
# > mix run priv/repo/insert_coder.exs Whitney emailwhitney@gmail.com
# > mix run priv/repo/insert_seeds.exs

alias RTLWeb.{Endpoint, Router}
alias RTL.Factory
alias RTL.Accounts

[name, email] = System.argv
coder = Factory.insert_user(%{full_name: name, email: email})
all_users = Accounts.get_all_users

IO.puts "Added coder \"#{coder.full_name}\"."
IO.puts "There are now #{length(all_users)} coders total."
IO.puts "Login paths:"

# TODO: Extract this logic to some helper module so I can de-duplicate
Enum.each(all_users, fn(user) ->
  path = Router.Helpers.session_path(Endpoint, :login_from_uuid, user.uuid)
  IO.puts "* #{user.full_name} logs in with: http://#{System.get_env("HOST_NAME")}#{path}"
end)
