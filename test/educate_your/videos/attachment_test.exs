defmodule RTL.Videos.AttachmentTest do
  use RTL.DataCase, async: true
  alias RTL.Videos.Attachment

  def bucket, do: RTL.Helpers.env("S3_BUCKET")

  # TODO: Ideally create a new file each time with a random name, so writing to
  # S3 is truly exercised
  test "stores correctly on S3" do
    {:ok, filename} = Attachment.store({"test/files/test_file.txt", "text"})
    assert filename == "test_file.txt"
    url = Attachment.url({filename, "text"})

    assert url == "https://s3.amazonaws.com/#{bucket()}/uploads/text/test_file.txt"

    response = HTTPotion.get(url)
    assert response.body == "This is the file's content.\n"
    assert :ok = Attachment.delete({filename, "text"})
  end
end
