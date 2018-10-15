defmodule RTL.PlaylistTest do
  use RTL.DataCase, async: true

  test "#search loads matching videos" do
    video1 = insert_video_with_tags(["abc", "Def:15:49", "ghi:40:72"])
    _video2 = insert_video_with_tags(["Def:10:20", "abc:30:40"])
    _video3 = insert_video_with_tags([])
    video4 = insert_video_with_tags(["Def:15:38", "abc:30:60", "Def:55:82"])

    tags = [%{text: "abc"}, %{text: "Def"}]
    results = summarize_segments(RTL.Playlist.build_playlist(tags))
    # - video1 has one matching segment (a global tag & a segment tag)
    # - video2 has the right tags, but no overlap
    # - video3 has no matching tags so it's excluded
    # - video4 has two separate sections where both of these tags apply
    assert Enum.sort(results) == Enum.sort([
      %{video_id: video1.id, starts_at: 15, ends_at: 49},
      %{video_id: video4.id, starts_at: 30, ends_at: 38},
      %{video_id: video4.id, starts_at: 55, ends_at: 60}
    ])
  end

  test "#search loads all videos when no tags applied" do
    video1 = insert_video_with_tags(["abc", "Def:15:49", "ghi:40:72"])
    video2 = insert_video_with_tags(["Def:10:20", "abc:30:40"])
    _video3 = insert_video_with_tags([])
    video4 = insert_video_with_tags(["abc:30:60", "Def:15:49", "ghi:65:82"])

    segments = RTL.Playlist.build_playlist([])
    results = summarize_segments(segments)
    # - video1 has a global tag so it's fully included
    # - video2 has 2 non-overlapping tags so 2 segments are included
    # - video3 has no tags so it's excluded
    # - video4 has some overlapping and some non-overlapping tags, so 2 segments
    assert Enum.sort(results) == Enum.sort([
      %{video_id: video1.id, starts_at: 0, ends_at: 9999},
      %{video_id: video2.id, starts_at: 10, ends_at: 20},
      %{video_id: video2.id, starts_at: 30, ends_at: 40},
      %{video_id: video4.id, starts_at: 15, ends_at: 60},
      %{video_id: video4.id, starts_at: 65, ends_at: 82},
    ])
  end

  defp summarize_segments(segments) do
    Enum.map(segments, fn(s) -> Map.take(s, [:video_id, :starts_at, :ends_at]) end)
  end
end
