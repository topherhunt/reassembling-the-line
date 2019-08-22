# Given a connected database, S3 bucket, and local tmp/ folder containing all videos and
# thumbs referenced in the db, upload all videos & thumbs to the correct folder on S3
# Useful for bucket migrations etc.

alias RTL.Videos

Videos.list_videos() |> Enum.each(fn(video) ->
  IO.puts "Video #{video.id}..."
  IO.inspect(Videos.upload_recording("tmp/#{video.recording_filename}"))
  IO.inspect(Videos.upload_thumbnail("tmp/#{video.thumbnail_filename}"))
end)
