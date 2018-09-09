defmodule EducateYour.Uploaders.GenericAttachmentTest do
  use EducateYour.DataCase, async: true
  alias EducateYour.Uploaders.GenericAttachment
  alias EducateYour.Helpers

  # TODO: Ideally create a new file each time with a random name, so writing to
  # S3 is truly exercised
  test "stores correctly on S3" do
    {:ok, filename} = GenericAttachment.store({"test/files/test_file.txt", "text"})
    assert filename == "test_file.txt"
    url = GenericAttachment.url({filename, "text"})
    assert url == "https://s3.amazonaws.com/#{Helpers.env("S3_BUCKET")}/uploads/text/test_file.txt"
    response = HTTPotion.get(url)
    assert response.body == "This is the file's content.\n"
    assert :ok = GenericAttachment.delete({filename, "text"})
  end
end
