defmodule RTL.Videos.Services.ImportFromYoutube do
  alias RTL.Videos
  alias RTL.Videos.Attachment

  def run([tsv_filename: tsv_filename, prompt: prompt]) do
    File.stream!(tsv_filename)
    |> CSV.decode!(separator: ?\t)
    |> process_rows(prompt)
  end

  # Returns a map of return codes
  def process_rows(rows, prompt) do
    IO.puts("Running videos_import_youtube.exs on #{Enum.count(rows)} input rows.")

    rows
    |> Enum.map(fn row -> process_row(row, prompt) end)
    |> Enum.group_by(fn {code, _, _} -> code end)
  end

  def process_row(row, prompt) do
    case row do
      [url, title] ->
        import_if_needed(url, title, prompt)

      _ ->
        IO.puts("WARNING: This row looks invalid, skipping:")
        IO.inspect(row)
    end
  end

  def import_if_needed(url, title, prompt) do
    # TODO: Display "N out of N" tracker for each video
    if already_imported?(url) do
      IO.puts("\nVideo \"#{title}\" is already imported; skipping.")
      {:skip, url, nil}
    else
      IO.puts("\nImporting video \"#{title}\":")
      import_video(title, url, prompt)
    end
  end

  def already_imported?(url) do
    Videos.count_videos(source_url: url) > 0
  end

  def import_video(title, url, prompt) do
    case download_from_youtube(url) do
      {:ok, recording_path, thumbnail_path} ->
        IO.puts("Uploading to S3 and saving the record...")
        # Upload the attachments first, then create the Video record.
        {:ok, _, recording_filename} = Attachment.upload_file(recording_path)
        {:ok, _, thumbnail_filename} = Attachment.upload_file(thumbnail_path)

        Videos.insert_video!(%{
          prompt_id: prompt.id,
          title: title,
          source_url: url,
          recording_filename: recording_filename,
          thumbnail_filename: thumbnail_filename
        })

        {:ok, url, nil}

      {:error, message} ->
        {:error, url, message}
    end
  end

  def download_from_youtube(url) do
    IO.puts("Downloading from #{url}...")
    filename = RTL.Helpers.to_hash(url)

    # TODO: Set up youtube-dl with multiple fallback formats, and detect which
    # was chosen afterwards.
    {format, video_ext} = video_format_and_ext()

    try do
      {output, _status} = run_youtube_download_cmd(filename, video_ext, format, url)
      recording_path = "tmp/#{filename}.#{video_ext}"
      thumbnail_path = "tmp/#{filename}.jpg"

      if File.exists?(recording_path) and File.exists?(thumbnail_path) do
        {:ok, recording_path, thumbnail_path}
      else
        IO.puts("Download failed with output: \n=====\n#{output}\n=====")
        {:error, output}
      end
    rescue
      e in RuntimeError ->
        IO.puts("Download hit exception: #{Exception.message(e)}")
        {:error, Exception.message(e)}
    end
  end

  def video_format_and_ext do
    case System.get_env("FORMAT") do
      # mp4 is better cross-browser, but not always available
      "18" -> {18, "mp4"}
      # webm is less compatible, but more reliably present
      "43" -> {43, "webm"}
      # Default to webm for now
      nil -> {43, "webm"}
    end
  end

  def run_youtube_download_cmd(filename, video_ext, format, url) do
    System.cmd(
      "youtube-dl",
      [
        "-o",
        "#{filename}.#{video_ext}",
        "-f#{format}",
        "--write-thumbnail",
        "--no-playlist",
        url
      ],
      cd: "tmp",
      stderr_to_stdout: true
    )
  end
end
