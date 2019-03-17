defmodule RTLWeb.ExploreControllerTest do
  use RTLWeb.ConnCase, async: true

  test "#index renders the page (no login needed)", %{conn: conn} do
    conn = get(conn, explore_path(conn, :index))
    assert html_response(conn, 200) =~ "Explore"
  end

  test "#playlist returns a JSON playlist for this search", %{conn: conn} do
    video1 = insert_video_with_tags(["abc", "def:15:49", "ghi:40:72"])
    _video2 = insert_video_with_tags(["def:10:20", "abc:30:40"])
    _video3 = insert_video_with_tags([])
    video4 = insert_video_with_tags(["def:15:38", "abc:30:60", "ghi:55:82"])

    conn = get(conn, explore_path(conn, :playlist), tags: "abc,ghi")
    segments = json_response(conn, 200)["playlist"]
    summaries = Enum.map(segments, fn s -> summarize_segment(s) end)

    expected = [
      "Video ##{video1.id} (40.0-72.0) [abc, def, ghi]",
      "Video ##{video4.id} (55.0-60.0) [abc, ghi]"
    ]

    assert Enum.sort(summaries) == Enum.sort(expected)
  end

  defp summarize_segment(s) do
    tag_texts = s["tags"] |> Enum.map(& &1["text"]) |> Enum.join(", ")
    "Video ##{s["video_id"]} (#{s["starts_at"]}-#{s["ends_at"]}) [#{tag_texts}]"
  end
end
