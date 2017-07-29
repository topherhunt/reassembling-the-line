##
# Export all videos in the local db to an executable dump file, which you can
# run in another environment to recreate the videos there.
#

alias EducateYour.{Repo, Video}

defmodule H do
  def clean(string) do
    String.replace(string, "\"", "")
  end
end

timestamp = Timex.now |> Timex.format!("%Y-%m-%d_%H-%M-%S", :strftime)
filename = "#{timestamp}_videos_export.exs"
{:ok, file} = File.open(filename, [:write])
IO.puts "Running export_videos_to_dump.exs which will write to #{filename}."
IO.binwrite(file, "alias EducateYour.{Repo, Video}")

Repo.all(Video)
  |> Enum.each(fn(video) ->
    IO.binwrite(file, "\n
    Repo.insert!(%Video{
      title: \"#{H.clean(video.title)}\",
      source_name: \"#{H.clean(video.source_name)}\",
      source_url: \"#{H.clean(video.source_url)}\",
      recording_filename: \"#{H.clean(video.recording_filename)}\",
      thumbnail_filename: \"#{H.clean(video.thumbnail_filename)}\"
    })")
  end)

IO.puts "Done exporting videos."
