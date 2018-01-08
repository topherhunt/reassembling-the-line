##
# Export all videos in the local db to an executable dump file, which you can
# run in another environment to recreate the videos there.
# Usage:
# - Import videos into your local database
# - `mix run priv/repo/export_videos_to_dump.exs`
# - See the output for the name of the dump file
# - Copy the contents of the dumpfile and paste them into your production
#   IEx console to recreate the identical records.
#

alias EducateYour.{Repo, Video}

defmodule H do
  def clean(string) do
    String.replace(string, "\"", "")
  end
end

timestamp = Timex.now |> Timex.format!("%Y-%m-%d_%H-%M-%S", :strftime)
filename = "#{timestamp}_videos_export.exs"
num_videos = Repo.count(Video)
{:ok, file} = File.open(filename, [:write])
IO.puts "Running export_videos_to_dump.exs which will write to #{filename}."
IO.puts "There are #{num_videos} videos in your local db."
IO.binwrite(file, "alias EducateYour.{Repo, Video}\n")

Repo.all(Video)
  |> Enum.each(fn(video) ->
    IO.binwrite(file, "Repo.insert!(%Video{title: \"#{H.clean(video.title)}\", source_name: \"#{H.clean(video.source_name)}\", source_url: \"#{H.clean(video.source_url)}\", recording_filename: \"#{H.clean(video.recording_filename)}\", thumbnail_filename: \"#{H.clean(video.thumbnail_filename)}\"})\n")
  end)

IO.binwrite(file, "IO.puts \"Import is complete. This should have imported #{num_videos} videos. Currently there are \#{Repo.count(Video)} videos total in this database.\"\n")

IO.puts "Done exporting videos."
