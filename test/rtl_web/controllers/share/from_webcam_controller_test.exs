defmodule RTLWeb.Share.FromWebcamControllerTest do
  use RTLWeb.ConnCase, async: true
  alias RTL.Videos

  defp create_path(conn, project, prompt) do
    Routes.share_from_webcam_path(conn, :create, project, prompt)
  end

  defp thank_you_path(conn, project, prompt) do
    Routes.share_from_webcam_path(conn, :thank_you, project, prompt)
  end

  defp valid_params(prompt) do
    %{
      "video" => %{
        "prompt_id" => prompt.id,
        "source_name" => "Elmer Fudd",
        "permission" => "researchers",
        "thumbnail_filename" => "abc.jpg",
        "recording_filename" => "abc.webm"
      }
    }
  end

  describe "#new" do
    test "renders correctly", %{conn: conn} do
      project = Factory.insert_project()
      prompt = Factory.insert_prompt(project_id: project.id)

      conn = get(conn, Routes.share_from_webcam_path(conn, :new, project, prompt))

      assert html_response(conn, 200) =~ "test-page-new-from-webcam"
    end
  end

  describe "#create" do
    test "inserts the video and redirects", %{conn: conn} do
      project = Factory.insert_project()
      prompt = Factory.insert_prompt(project_id: project.id)

      params = valid_params(prompt)
      conn = post(conn, create_path(conn, project, prompt), params)

      assert redirected_to(conn) == thank_you_path(conn, project, prompt)
      video = Videos.get_video_by(order: :newest)
      assert video.source_name == "Elmer Fudd"
      assert video.title == "Interview with Elmer Fudd"
      assert video.permission == "researchers"
      assert video.thumbnail_filename == "abc.jpg"
      assert video.recording_filename == "abc.webm"
    end

    test "tolerates absent source_name", %{conn: conn} do
      project = Factory.insert_project()
      prompt = Factory.insert_prompt(project_id: project.id)

      params = put_in(valid_params(prompt), ["video", "source_name"], nil)
      post(conn, create_path(conn, project, prompt), params)

      video = Videos.get_video_by(order: :newest)
      assert video.source_name == nil
      assert video.title == "Anonymous interview"
    end
  end
end
