defmodule RTL.DataHelpers do
  alias RTL.Factory
  alias RTL.Accounts
  alias RTL.Videos

  # TODO: This can be moved to the factories too, since it serves similar purpose
  def empty_database do
    # Clean out cruft records possibly left over by earlier (crashed) tests...?
    Accounts.delete_all_users()
    Videos.delete_all_content()
  end

  # Usage: `video4 = insert_video_with_tags(["abc:30:60", "Def:15:49", "ghi:65:82"])`
  # TODO: I feel like this belongs in the factory?
  def insert_video_with_tags(video_params \\ %{}, tag_strings) do
    video = Factory.insert_video(video_params)
    Factory.insert_coding(video_id: video.id, tags: tag_strings_to_maps(tag_strings))
    video
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
