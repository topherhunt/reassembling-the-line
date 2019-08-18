defmodule RTL.PlaylistTest do
  use RTL.DataCase, async: true

  test "#search loads matching videos" do
    project = Factory.insert_project()
    prompt = Factory.insert_prompt(project_id: project.id)

    # video1 has one matching segment (a "global" tag & a segment tag)
    video1 = add_tagged_video(prompt, [{"abc", 0, 999}, {"def", 15, 49}, {"ghi", 40, 72}])

    # video2 has the right tags, but no overlap
    _video2 = add_tagged_video(prompt, [{"def", 10, 20}, {"abc", 30, 40}])

    # video3 has no matching tags so it's excluded
    _video3 = add_tagged_video(prompt, [])

    # video4 has two separate sections where both of these tags apply
    video4 = add_tagged_video(prompt, [{"def", 15, 38}, {"abc", 30, 60}, {"def", 55, 82}])

    segments = RTL.Playlist.build_playlist(project, [%{name: "abc"}, %{name: "def"}])
    results = summarize_segments(segments)

    expected = [
      %{video_id: video1.id, starts_at: 15.0, ends_at: 49.0},
      %{video_id: video4.id, starts_at: 30.0, ends_at: 38.0},
      %{video_id: video4.id, starts_at: 55.0, ends_at: 60.0}
    ]

    assert Enum.sort(results) == Enum.sort(expected)
  end

  test "#search loads all videos when no tags applied" do
    project = Factory.insert_project()
    prompt = Factory.insert_prompt(project_id: project.id)

    # video1 has a "global" tag so it's fully included
    video1 = add_tagged_video(prompt, [{"abc", 0, 999}, {"def", 15, 49}, {"ghi", 40, 72}])

    # video2 has 2 non-overlapping tags so 2 segments are included
    video2 = add_tagged_video(prompt, [{"def", 10, 20}, {"abc", 30, 40}])

    # video3 has no tags so it's excluded
    _video3 = add_tagged_video(prompt, [])

    # video4 has some overlapping and some non-overlapping tags, so 2 segments
    video4 = add_tagged_video(prompt, [{"abc", 30, 60}, {"def", 15, 49}, {"ghi", 65, 82}])

    segments = RTL.Playlist.build_playlist(project, [])
    results = summarize_segments(segments)

    expected = [
      %{video_id: video1.id, starts_at: 0.0, ends_at: 999.0},
      %{video_id: video2.id, starts_at: 10.0, ends_at: 20.0},
      %{video_id: video2.id, starts_at: 30.0, ends_at: 40.0},
      %{video_id: video4.id, starts_at: 15.0, ends_at: 60.0},
      %{video_id: video4.id, starts_at: 65.0, ends_at: 82.0}
    ]

    assert Enum.sort(results) == Enum.sort(expected)
  end

  #
  # Helpers
  #

  defp add_tagged_video(prompt, tags) do
    Factory.insert_video(prompt_id: prompt.id, coded_with_tags: tags)
  end

  defp summarize_segments(segments) do
    Enum.map(segments, &Map.take(&1, [:video_id, :starts_at, :ends_at]))
  end
end
