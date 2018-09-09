# mix run priv/repo/autologins.exs

alias EducateYour.Repo
alias EducateYour.Schemas.User
alias EducateYourWeb.{Endpoint, Router}

IO.puts "Autologin paths:"
Repo.all(User) |> Enum.each(fn(user) ->
  path = Router.Helpers.session_path(Endpoint, :login_from_uuid, user.uuid)
  IO.puts "* #{user.full_name}: #{path}"
end)
