# Given a connected database, S3 bucket, and local tmp/ folder containing all videos and
# thumbs referenced in the db, upload all videos & thumbs to the correct folder on S3
# Useful for bucket migrations etc.

alias RTL.Videos
alias RTL.Videos.Attachment

Videos.list_videos() |> Enum.each(fn(video) ->
  IO.puts "Video #{video.id}..."
  IO.inspect(Attachment.upload_file("recording", "tmp/#{video.recording_filename}"))
  IO.inspect(Attachment.upload_file("thumbnail", "tmp/#{video.thumbnail_filename}"))
end)
