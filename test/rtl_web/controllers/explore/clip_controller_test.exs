defmodule RTLWeb.Explore.ClipControllerTest do
  use RTLWeb.ConnCase, async: true

  describe "#index" do
    test "renders the page (no login needed)", %{conn: conn} do
      project = Factory.insert_project()

      conn = get(conn, Routes.explore_clip_path(conn, :index, project))

      assert html_response(conn, 200) =~ "test-page-explore-clip-index"
    end
  end

  describe "#playlist" do
    test "returns a JSON playlist for this search", %{conn: conn} do
      project = Factory.insert_project()
      prompt = Factory.insert_prompt(project_id: project.id)
      # TODO: These helpers have the wrong boundary or something.
      # Consider piping: Factory.insert_video(whatever_params) |> Factory.tag_video(tags)
      video1 = add_tagged_video(prompt, [{"abc", 0, 999}, {"def", 15, 49}, {"ghi", 40, 72}])
      _video2 = add_tagged_video(prompt, [{"def", 10, 20}, {"abc", 30, 40}])
      _video3 = add_tagged_video(prompt, [])
      video4 = add_tagged_video(prompt, [{"def", 15, 38}, {"abc", 30, 60}, {"ghi", 55, 82}])

      conn = get(conn, Routes.explore_clip_path(conn, :playlist, project), tags: "abc,ghi")
      segments = json_response(conn, 200)["playlist"]
      summaries = Enum.map(segments, fn s -> summarize_segment(s) end)

      expected = [
        "Video ##{video1.id} (40.0-72.0) [abc, def, ghi]",
        "Video ##{video4.id} (55.0-60.0) [abc, ghi]"
      ]

      assert Enum.sort(summaries) == Enum.sort(expected)
    end
  end

  #
  # Helpers
  #

  defp add_tagged_video(prompt, tags) do
    Factory.insert_video(prompt_id: prompt.id, coded_with_tags: tags)
  end

  defp summarize_segment(s) do
    tag_names = s["tags"] |> Enum.map(& &1["name"]) |> Enum.join(", ")
    "Video ##{s["video_id"]} (#{s["starts_at"]}-#{s["ends_at"]}) [#{tag_names}]"
  end
end
