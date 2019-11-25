# High-level coverage of the manage videos & coding UI, including the videos list LV.
# See CodingControllerTest for the CRUD basics.

defmodule RTLWeb.RecordingPageTest do
  use RTLWeb.IntegrationCase

  hound_session()

  # I keep showing the form by default to make styling work easier.
  # This test ensures I can't forget to hide it again.
  test "the post-video form is hidden by default", %{conn: conn} do
    project = Factory.insert_project()
    prompt = Factory.insert_prompt(project_id: project.id)

    navigate_to Routes.video_path(conn, :new, project, prompt)

    assert_text "Read the question. Think about what you want to say."
    refute_text "Your video is ready!"
  end
end
