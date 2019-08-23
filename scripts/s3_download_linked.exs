# Given a connected database and S3 bucket, download all videos & thumbnails referenced
# in the db from S3 to a local tmp folder. Useful for bucket migrations etc.

alias RTL.Videos

System.cmd("rm", ["-rf", "tmp"])
System.cmd("mkdir", ["tmp"])

IO.puts "Downloading all recordings & thumbnails referenced in the DB from S3 to tmp/."

Videos.list_videos() |> Enum.each(fn(video) ->
  IO.puts "Video #{video.id}..."
  # TODO: Instead of using wget, see if I can use httpotion or httpoison to download the
  # binaries so I can more easily confirm command success.
  System.cmd("wget", [Videos.video_recording_url(video), "-P", "./tmp"])
  System.cmd("wget", [Videos.video_thumbnail_url(video), "-P", "./tmp"])
end)
