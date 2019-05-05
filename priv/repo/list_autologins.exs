# mix run priv/repo/autologins.exs

alias RTLWeb.Endpoint
alias RTLWeb.Router.Helpers, as: Routes
alias RTL.Accounts

IO.puts "Autologin paths:"
Accounts.get_users |> Enum.each(fn(user) ->
  path = Routes.auth_path(Endpoint, :force_login, user.uuid)
  IO.puts "* #{user.full_name} (#{user.email}):  http://#{System.get_env("HOST_NAME")}#{path}"
end)
