defmodule EducateYour.GenericAttachmentTest do
  use EducateYour.ModelCase, async: true
  alias EducateYour.{GenericAttachment}

  # TODO: Ideally create a new file each time with a random name, so writing to
  # S3 is truly exercised
  test "stores correctly on S3" do
    {:ok, filename} = GenericAttachment.store({"test/files/test_file.txt", "text"})
    assert filename == "test_file.txt"
    url = GenericAttachment.url({filename, "text"})
    assert url == "https://s3.amazonaws.com/educate-your-dev/uploads/text/test_file.txt"
    response = HTTPotion.get(url)
    assert response.body == "This is the file's content.\n"
    assert :ok = GenericAttachment.delete({filename, "text"})
  end
end
