# mix run priv/repo/autologins.exs

alias EducateYour.{Repo, Router, Endpoint, User}

IO.puts "Autologin links:"
User |> Repo.all |> Enum.each(fn(user) ->
  url = Router.Helpers.session_url(Endpoint, :login_from_uuid, user.uuid)
  IO.puts "- #{user.full_name}: #{url}"
end)
