##
# For each row in `import_youtube_videos.tsv`, download the video at the given
# URL, create a video record in the local DB, and upload the video to S3.
#
# To run it:
# - Must be run on Mac OSX
# - The Brew package `youtube-dl` must be installed
# - Create import_youtube_videos.tsv in this folder, following the sample file
# - `mix run priv/repo/import_videos.exs`
# - You can re-run it idempotently; it will skip any videos already imported,
#   and retry any failures.
# - Set env var FORMAT=18 to download everything as mp4 instead of webm (default)
#

import Ecto.Query
alias EducateYour.{Repo, Video, GenericAttachment}

defmodule YoutubeImporter do
  def import_if_needed(title, url) do
    # TODO: Display "N out of N" tracker for each video
    if already_imported?(url) do
      IO.puts "Video \"#{title}\" is already imported; skipping."
      {:skip, url, nil}
    else
      IO.puts "Video \"#{title}\" needs importing."
      import_video(title, url)
    end
  end

  def already_imported?(url) do
    (Video |> where([v], v.source_url == ^url) |> Repo.count) > 0
  end

  def import_video(title, url) do
    case download_from_youtube(url) do
      {:ok, recording_path, thumbnail_path} ->
        IO.puts "Uploading to S3 and saving the record..."
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
      {:error, message} ->
        {:error, url, message}
    end
  end

  def download_from_youtube(url) do
    IO.puts "Downloading from url #{url}..."
    filename = Video.hashed_url(url)

    # TODO: Set up youtube-dl with multiple fallback formats, and detect which
    # was chosen afterwards.
    {format, video_ext} = case System.get_env("FORMAT") do
      "43" -> {43, "webm"} # This is the most common format. Size varies.
      "18" -> {18, "mp4"}  # Some videos don't have webm, so fall back to this
      nil  -> {43, "webm"}
    end

    try do
      {output, _status} = System.cmd(
        "youtube-dl", ["-o", "#{filename}.#{video_ext}", "-f#{format}", "--write-thumbnail", "--no-playlist", url],
        cd: "tmp",
        stderr_to_stdout: true
      )
      recording_path = "tmp/#{filename}.#{video_ext}"
      thumbnail_path = "tmp/#{filename}.jpg"
      if File.exists?(recording_path) and File.exists?(thumbnail_path) do
        IO.puts "Download succeeded."
        {:ok, recording_path, thumbnail_path}
      else
        IO.puts "Download failed with output: \n=====\n#{output}\n====="
        {:error, output}
      end
    rescue
      e in RuntimeError ->
        IO.puts "Download hit exception: #{Exception.message(e)}"
        {:error, Exception.message(e)}
    end
  end
end

IO.puts "NOTE: Existing videos are NOT cleared out first."
IO.puts "You'll need to clear them out yourself if you want a clean import."

original_videos_count = Repo.count(Video)

rows = File.stream!("import_youtube_videos.tsv") |> CSV.decode!(separator: ?\t)
IO.puts "Running import_youtube_videos.exs on #{Enum.count(rows)} input rows."
System.cmd("mkdir", ["tmp"])

results = rows
  |> Enum.map(fn([title, url]) -> YoutubeImporter.import_if_needed(title, url) end)
  |> Enum.group_by(fn({code, _, _}) -> code end)
oks    = results[:ok]    || []
skips  = results[:skip]  || []
errors = results[:error] || []
new_videos_count = Repo.count(Video) - original_videos_count
IO.puts "\n=====\nDone! #{new_videos_count} videos imported."
IO.puts "\nSkipped #{length(skips)} videos which were already imported:"
Enum.each(skips, fn({:skip, url, _}) -> IO.puts("* #{url}") end)
IO.puts "\nSuccessfully imported #{length(oks)} videos:"
Enum.each(oks, fn({:ok, url, _}) -> IO.puts("* #{url}") end)
IO.puts "\nAnd hit #{length(errors)} errors:\n"
Enum.each(errors, fn({:error, url, msg}) -> IO.puts("* #{url}:\n#{msg}\n") end)
IO.puts "Temp files are NOT auto removed. Remove them with: `rm -rf tmp`"
