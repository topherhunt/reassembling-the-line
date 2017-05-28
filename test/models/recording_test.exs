defmodule Zb.RecordingTest do
  use Zb.ModelCase, async: true

  # NOTE: Keeping this proof-of-concept for historical purposes.
  # In this app we probably won't use Arc file attachments.
  # test "Proof-of-concept: S3 file attachment upload and download" do
  #   interview = %Zb.Interview{id: 42}
  #   {:ok, file_contents} = File.read("test/files/test_file.txt")
  #   {:ok, filename} = Zb.Recording.store({"test/files/test_file.txt", interview})
  #   assert filename == "test_file.txt"
  #   url = Zb.Recording.url({filename, interview})
  #   assert url =~ "/uploads/interview_recordings/42.webm/test_file.txt"
  #   response = HTTPotion.get(url)
  #   assert response.body == file_contents
  #   assert :ok = Zb.Recording.delete({filename, interview})
  # end
end
