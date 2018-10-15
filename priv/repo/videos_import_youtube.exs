# Given a list of Youtube videos, download each video file, upload it to S3, and
# insert a Video record for it in the local DB.
#
# Usage:
# - Ensure `youtube-dl` is installed (Homebrew works well)
# - If you want a fresh start, first delete all videos from the local DB and
#   the specified S3 bucket.
# > S3_BUCKET=bucket_name mix run priv/repo/videos_import_youtube.exs videos.tsv
# - It's idempotent; re-running it will skip any done videos and retry any failures.
#
# Arguments:
# - The first arg is the filename of the .tsv where the videos are listed.
#   The path defaults to the project root. The .tsv should have 2 columns for
#   name and title, and should not have a header row.
# - Set env var S3_BUCKET=bucket_name to specify where videos should be uploaded
# - Set env var FORMAT=18 to download everything as .mp4 (default is .webm)
#

alias EducateYour.Services.YoutubeImporter
alias EducateYour.Videos

IO.puts "Importing Youtube videos into the local DB and the S3 bucket #{System.get_env("S3_BUCKET")}."

tsv_filename = System.argv() |> Enum.at(0)
System.cmd("mkdir", ["tmp"])

original_videos_count = Videos.count_all_videos
results = YoutubeImporter.process_tsv(tsv_filename)
new_videos_count = Videos.count_all_videos - original_videos_count

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
