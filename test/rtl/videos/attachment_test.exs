defmodule RTL.Videos.AttachmentTest do
  use RTL.DataCase, async: true
  alias RTL.Videos.Attachment
  alias RTL.Helpers, as: H

  def bucket, do: H.env!("S3_BUCKET")

  test "uploading, downloading, and deleting files works" do
    ensure_network_connection()
    {local_path, contents} = create_random_file()

    {:ok, url, filename} = Attachment.upload_file(local_path)

    assert url == Attachment.url(filename)
    assert filename == Path.basename(local_path)
    assert HTTPotion.get!(url).body == contents
    Attachment.delete_file(filename)
  end

  test "presigned_upload_url works" do
    ensure_network_connection()
    {local_path, contents} = create_random_file()
    filename = Path.basename(local_path)

    upload_url = Attachment.presigned_upload_url(filename)
    HTTPotion.put!(upload_url,
      body: contents,
      headers: ["Content-Type": "binary/octet-stream"]
    )
    retrieval_url = Attachment.url(filename)
    assert HTTPotion.get!(retrieval_url).body == contents
  end

  #
  # Helpers
  #

  defp ensure_network_connection do
    unless HTTPotion.get("http://httpbin.org/get") |> HTTPotion.Response.success?() do
      raise "Looks like you're not connected to the internet. Skipping S3-related tests."
    end
  end

  defp create_random_file do
    path = "tmp/#{Factory.random_uuid()}.txt"
    contents = Factory.random_uuid()
    File.write!(path, contents)
    {path, contents}
  end
end
