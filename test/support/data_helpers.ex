defmodule RTL.DataHelpers do
  alias RTL.Accounts
  alias RTL.Videos

  # TODO: This can be moved to the factories too, since it serves similar purpose
  def empty_database do
    # Clean out cruft records possibly left over by earlier (crashed) tests...?
    Accounts.delete_all_users()
    Videos.delete_all_content()
  end

  def tag_strings_to_maps(strings) do
    Enum.map(strings, fn string ->
      case String.split(string, ":") do
        [text] -> %{"text" => text}
        [text, s, e] -> %{"text" => text, "starts_at" => s, "ends_at" => e}
      end
    end)
  end
end
