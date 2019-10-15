# Populate session_token for all users where it's absent.

alias RTL.Accounts

Accounts.get_users() |> Enum.map(fn user -> Accounts.update_user!(user, %{}) end)

IO.puts "Done."
