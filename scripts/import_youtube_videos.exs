# Given a list of Youtube videos, download each video file, upload it to S3, and
# insert a Video record for it in the local DB.
#
# Setup:
#   * `youtube-dl` must be installed. (to install w Homebrew: `brew install youtube-dl`)
#   * If you want a fresh start, `mix resetdb` then create a new Project and Prompt
#   * Ensure S3_BUCKET points to the bucket where the videos should be uploaded
#
# Usage:
#   * `mix run priv/repo/import_youtube_videos.exs PROMPT_UUID VIDEOS_TSV_FILENAME`
#   * or use the alias: `mix import_youtube_videos PRMOPT_UUID VIDEOS_TSV_FILENAME`
#   * It's idempotent; re-running it will skip any done videos and retry any failures.
#
# Arguments:
#   * The prompt UUID. Create a project, create a prompt, then get the uuid from the URL.
#   * The filename of a .tsv list of videos to import (or path, relative to the project
#     root). The tsv should have two columns: 1) the Youtube video url and 2) video name.
#     The tsv should not have a header row.
#
# Env settings:
#   * Optionally set S3_BUCKET=<bucket_name> to specify which bucket to upload the vids to
#   * Optionally set FORMAT=18 to download all videos as .mp4 (default is .webm)
#

alias RTL.Videos.Services.ImportFromYoutube
alias RTL.Videos

IO.puts "Importing Youtube videos into the local DB and the S3 bucket #{System.get_env("S3_BUCKET")}."

[prompt_uuid, tsv_filename] = System.argv()
prompt = RTL.Projects.get_prompt_by!(uuid: prompt_uuid)

System.cmd("mkdir", ["tmp"])

orig_videos_count = Videos.count_videos()
results = ImportFromYoutube.run(tsv_filename: tsv_filename, prompt: prompt)
new_videos_count = Videos.count_videos() - orig_videos_count

oks    = results[:ok]    || []
skips  = results[:skip]  || []
errors = results[:error] || []
IO.puts "\n=====\nDone! #{new_videos_count} videos imported."
IO.puts "\nSkipped #{length(skips)} videos which were already imported:"
Enum.each(skips, fn({:skip, url, _}) -> IO.puts("* #{url}") end)
IO.puts "\nSuccessfully imported #{length(oks)} videos:"
Enum.each(oks, fn({:ok, url, _}) -> IO.puts("* #{url}") end)
IO.puts "\nAnd hit #{length(errors)} errors:\n"
Enum.each(errors, fn({:error, url, msg}) -> IO.puts("* #{url}:\n#{msg}\n") end)
IO.puts "Temp files are NOT auto removed. Remove them with: `rm -rf tmp`"
