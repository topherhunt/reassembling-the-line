# TODO: Try moving this to a Videos context test
defmodule RTL.VideosTest do
  use RTL.DataCase, async: true
  alias RTL.Videos

  describe "scopes" do
    test "fetching all coded videos having certain tags" do
      v1 = insert_video_with_tags(["abc:1:2"])
      v2 = insert_video_with_tags(["def:1:2"])
      v3 = insert_video_with_tags(["abc:1:2", "def:1:2"])
      v4 = insert_video_with_tags(["abc:1:2", "ghi:1:2", "def:1:2"])
      v5 = insert_video_with_tags([])
      v6 = insert_video_with_tags(["ghi:1:2", "jkl:1:2", "def:1:2"])

      filter_tags = [%{text: "abc"}, %{text: "def"}]
      videos = Videos.get_videos(coded: true, having_tags: filter_tags)
      video_ids = Enum.map(videos, & &1.id) |> Enum.sort()

      assert v1.id not in video_ids
      assert v2.id not in video_ids
      assert v3.id in video_ids
      assert v4.id in video_ids
      assert v5.id not in video_ids
      assert v6.id not in video_ids
    end
  end
end
