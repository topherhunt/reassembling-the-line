# mix run priv/repo/autologins.exs

alias RTLWeb.{Endpoint, Router}
alias RTL.Accounts

IO.puts "Autologin paths:"
Accounts.get_all_users |> Enum.each(fn(user) ->
  path = Router.Helpers.session_path(Endpoint, :login_from_uuid, user.uuid)
  IO.puts "* #{user.full_name}: #{path}"
end)
