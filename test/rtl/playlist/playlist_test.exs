defmodule RTL.PlaylistTest do
  use RTL.DataCase, async: true

  defp insert_tagged_video(prompt, tags) do
    insert_video_with_tags([prompt_id: prompt.id], tags)
  end

  test "#search loads matching videos" do
    project = Factory.insert_project()
    prompt = Factory.insert_prompt(project_id: project.id)
    # video1 has one matching segment (a global tag & a segment tag)
    video1 = insert_tagged_video(prompt, ["abc", "Def:15:49", "ghi:40:72"])
    # video2 has the right tags, but no overlap
    _video2 = insert_tagged_video(prompt, ["Def:10:20", "abc:30:40"])
    # video3 has no matching tags so it's excluded
    _video3 = insert_tagged_video(prompt, [])
    # video4 has two separate sections where both of these tags apply
    video4 = insert_tagged_video(prompt, ["Def:15:38", "abc:30:60", "Def:55:82"])

    tags = [%{text: "abc"}, %{text: "Def"}]
    segments = RTL.Playlist.build_playlist(project, tags)
    results = summarize_segments(segments)

    expected = [
      %{video_id: video1.id, starts_at: 15, ends_at: 49},
      %{video_id: video4.id, starts_at: 30, ends_at: 38},
      %{video_id: video4.id, starts_at: 55, ends_at: 60}
    ]

    assert Enum.sort(results) == Enum.sort(expected)
  end

  test "#search loads all videos when no tags applied" do
    project = Factory.insert_project()
    prompt = Factory.insert_prompt(project_id: project.id)
    # video1 has a global tag so it's fully included
    video1 = insert_tagged_video(prompt, ["abc", "Def:15:49", "ghi:40:72"])
    # video2 has 2 non-overlapping tags so 2 segments are included
    video2 = insert_tagged_video(prompt, ["Def:10:20", "abc:30:40"])
    # video3 has no tags so it's excluded
    _video3 = insert_tagged_video(prompt, [])
    # video4 has some overlapping and some non-overlapping tags, so 2 segments
    video4 = insert_tagged_video(prompt, ["abc:30:60", "Def:15:49", "ghi:65:82"])

    segments = RTL.Playlist.build_playlist(project, [])
    results = summarize_segments(segments)

    expected = [
      %{video_id: video1.id, starts_at: 0, ends_at: 9999},
      %{video_id: video2.id, starts_at: 10, ends_at: 20},
      %{video_id: video2.id, starts_at: 30, ends_at: 40},
      %{video_id: video4.id, starts_at: 15, ends_at: 60},
      %{video_id: video4.id, starts_at: 65, ends_at: 82}
    ]

    assert Enum.sort(results) == Enum.sort(expected)
  end

  defp summarize_segments(segments) do
    Enum.map(segments, &Map.take(&1, [:video_id, :starts_at, :ends_at]))
  end
end
