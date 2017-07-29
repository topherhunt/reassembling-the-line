##
# For each row in `import_youtube_videos.tsv`, download the video at the given
# URL, create a video record in the local DB, and upload the video to S3.
#
# To run it:
# - Must be run on Mac OSX
# - The Brew package `youtube-dl` must be installed
# - Create import_youtube_videos.tsv in this folder, following the sample file
# - `mix run priv/repo/import_videos.exs`
#
# TODO: Open questions:
# - What format should I use as default?

import Ecto.Query
alias EducateYour.{H, Repo, Video, GenericAttachment}

defmodule YoutubeImporter do
  def import(title, url) do
    IO.puts "Downloading \"#{title}\"..."
    hex = H.random_hex()
    # TODO: Determine what format is most universal. May need fallbacks.
    format = "43"
    {output, status} = System.cmd(
      "youtube-dl",
      ["-o", "#{hex}.webm", "-f#{format}", "--write-thumbnail", "--no-playlist", url],
      cd: "tmp"
    )
    recording_path = "tmp/#{hex}.webm"
    thumbnail_path = "tmp/#{hex}.jpg"
    if File.exists?(recording_path) and File.exists?(thumbnail_path) do
      IO.puts "Downloaded. Uploading to S3 and saving the record..."
      # Upload the attachments first, then create the Video record.
      {:ok, recording_filename} = GenericAttachment.store({recording_path, "recording"})
      {:ok, thumbnail_filename} = GenericAttachment.store({thumbnail_path, "thumbnail"})
      params = %{
        title: title,
        source_name: "YouTube",
        source_url: url,
        recording_filename: recording_filename,
        thumbnail_filename: thumbnail_filename
      }
      Video.changeset(%Video{}, params) |> Repo.insert!
      {:ok, url, nil}
    else
      {:error, url, output}
    end
  end
end

IO.puts "Clearing out all existing videos..."
Repo.delete_all(Video)

rows = File.stream!("import_youtube_videos.tsv") |> CSV.decode!(separator: ?\t)
IO.puts "Running import_youtube_videos.exs on #{Enum.count(rows)} input rows."
System.cmd("mkdir", ["tmp"])

{successes, errors} = rows
  |> Enum.map(fn([title, url]) -> YoutubeImporter.import(title, url) end)
  |> Enum.partition(fn({code, _, _}) -> code == :ok end)

IO.puts "\n=====\nDone! #{Repo.count(Video)} videos created."
IO.puts "Successfully imported #{length(successes)} videos:"
Enum.each(successes, fn({:ok, url, _}) -> IO.puts("* #{url}") end)
IO.puts "And hit #{length(errors)} errors:\n"
Enum.each(errors, fn({:error, url, msg}) -> IO.puts("* #{url}:\n#{msg}\n") end)
IO.puts "Temp files are NOT auto removed. Remove them with: `rm -rf tmp`"
