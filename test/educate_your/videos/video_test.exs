# TODO: Try moving this to a Videos context test
defmodule RTL.VideoTest do
  use RTL.DataCase, async: true
  alias RTL.Videos.Video

  test "#tagged_with returns only videos tagged with all those tags" do
    v1 = insert_video_with_tags(["abc:1:2"])
    v2 = insert_video_with_tags(["def:1:2"])
    v3 = insert_video_with_tags(["abc:1:2", "def:1:2"]) # has both
    v4 = insert_video_with_tags(["abc:1:2", "def:1:2", "ghi:1:2"]) # has both
    v5 = insert_video_with_tags(["abc:1:2", "ghi:1:2", "jkl:1:2"])
    v6 = insert_video_with_tags([])

    videos = Video.tagged_with([%{text: "abc"}, %{text: "def"}]) |> Repo.all
    video_ids = Enum.map(videos, & &1.id) |> Enum.sort

    assert v1.id not in video_ids
    assert v2.id not in video_ids
    assert v3.id in video_ids
    assert v4.id in video_ids
    assert v5.id not in video_ids
    assert v6.id not in video_ids
  end
end
