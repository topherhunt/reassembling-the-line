# High-level coverage of the manage videos & coding UI, including the videos list LV.
# See CodingControllerTest for the CRUD basics.

defmodule RTLWeb.ExplorePageTest do
  use RTLWeb.IntegrationCase
  # alias RTL.{Projects, Videos}
  # alias RTL.Videos.{Tagging, Tag}

  hound_session()

  test "visitor can see list of available tags", %{conn: conn} do
    project = Factory.insert_project()
    Factory.insert_video(project_id: project.id, coded_with_tags: [{"apple", 5, 10}])

    navigate_to Routes.results_path(conn, :index, project)

    refute_text "we don't have any results yet"
  end

  test "shows a special message when no coded clips are available", %{conn: conn} do
    project = Factory.insert_project()
    v1 = Factory.insert_video(project_id: project.id)
    Factory.insert_coding(video_id: v1.id, tags: [{"apple", 40, 50}], completed_at: nil)

    navigate_to Routes.results_path(conn, :index, project)

    assert_text "we don't have any results yet"
  end
end
