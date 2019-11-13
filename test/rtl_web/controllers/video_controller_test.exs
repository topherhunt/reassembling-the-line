defmodule RTLWeb.VideoControllerTest do
  use RTLWeb.ConnCase, async: true
  alias RTL.Videos

  defp create_path(conn, project, prompt) do
    Routes.video_path(conn, :create, project, prompt)
  end

  defp thank_you_path(conn, project) do
    Routes.video_path(conn, :thank_you, project)
  end

  defp valid_params(prompt) do
    %{
      "video" => %{
        "prompt_id" => prompt.id,
        "speaker_name" => "Elmer Fudd",
        "permission_show_name" => true,
        "thumbnail_filename" => "abc.jpg",
        "recording_filename" => "abc.webm"
      }
    }
  end

  describe "#new" do
    test "renders correctly", %{conn: conn} do
      project = Factory.insert_project()
      prompt = Factory.insert_prompt(project_id: project.id)

      conn = get(conn, Routes.video_path(conn, :new, project, prompt))

      assert html_response(conn, 200) =~ "test-page-new-from-webcam"
    end
  end

  describe "#create" do
    test "inserts the video and redirects", %{conn: conn} do
      project = Factory.insert_project()
      prompt = Factory.insert_prompt(project_id: project.id)

      params = valid_params(prompt)
      conn = post(conn, create_path(conn, project, prompt), params)

      assert redirected_to(conn) == thank_you_path(conn, project)
      video = Videos.get_video_by(order: :newest)
      assert video.speaker_name == "Elmer Fudd"
      assert video.title == nil
      assert video.thumbnail_filename == "abc.jpg"
      assert video.recording_filename == "abc.webm"
    end
  end
end
