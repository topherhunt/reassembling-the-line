defmodule EducateYour.ExploreControllerTest do
  use EducateYour.ConnCase, async: true

  test "#index renders the page (no login needed)", %{conn: conn} do
    conn = get(conn, explore_path(conn, :index))
    assert html_response(conn, 200) =~ "Explore"
  end

  test "#playlist returns a JSON playlist for this search", %{conn: conn} do
    video1 = insert_video_with_tags(
      ["location:abc", "sentiment:def:15:49", "topic:ghi:40:72"])
    _video2 = insert_video_with_tags(
      ["sentiment:def:10:20", "location:abc:30:40"])
    _video3 = insert_video_with_tags([])
    video4 = insert_video_with_tags(
      ["sentiment:def:15:38", "location:abc:30:60", "topic:ghi:55:82"])

    conn = get(conn, explore_path(conn, :playlist), tags: "location:abc,topic:ghi")
    segments = json_response(conn, 200)["playlist"]
    summaries = Enum.map(segments, fn(s) -> summarize_segment(s) end)
    assert Enum.sort(summaries) == Enum.sort([
      "Video ##{video1.id} (40-72) [location:abc, sentiment:def, topic:ghi]",
      "Video ##{video4.id} (55-60) [location:abc, topic:ghi]"
    ])
  end

  defp summarize_segment(s) do
    tag_texts = s["tags"]
      |> Enum.map(fn(t) -> "#{t["context"]}:#{t["text"]}" end)
      |> Enum.join(", ")
    "Video ##{s["video_id"]} (#{s["starts_at"]}-#{s["ends_at"]}) [#{tag_texts}]"
  end
end
