defmodule RTLWeb.Collect.WebcamRecordingControllerTest do
  use RTLWeb.ConnCase, async: true
  alias RTL.Videos

  test "#new renders correctly", %{conn: conn} do
    conn = get(conn, Routes.collect_webcam_recording_path(conn, :new, %{}))

    assert html_response(conn, 200) =~
      "Read the questions and consider what you'd like to say."
  end

  test "#create inserts the video and redirects", %{conn: conn} do
    params = %{
      "video" => %{
        "source_name" => "Elmer Fudd",
        "permission" => "researchers",
        "thumbnail_filename" => "abc.jpg",
        "recording_filename" => "abc.webm"
      }
    }

    conn = post(conn, Routes.collect_webcam_recording_path(conn, :create), params)

    assert redirected_to(conn) == Routes.collect_webcam_recording_path(conn, :thank_you)
    video = Videos.get_newest_video()
    assert video.source_name == "Elmer Fudd"
    assert video.title == "Interview with Elmer Fudd"
    assert video.permission == "researchers"
    assert video.thumbnail_filename == "abc.jpg"
    assert video.recording_filename == "abc.webm"
  end

  test "#create tolerates absent source_name", %{conn: conn} do
    params = %{
      "video" => %{
        "source_name" => "",
        "thumbnail_filename" => "def.jpg",
        "recording_filename" => "def.webm"
      }
    }

    post(conn, Routes.collect_webcam_recording_path(conn, :create), params)

    video = Videos.get_newest_video()
    assert video.source_name == nil
    assert video.title == "Anonymous interview"
  end

  ##
  # Helpers
  #

  def create_params(video_id), do: %{"video_id" => video_id, "tags" => valid_tag_params()}

  def create_params(video_id, tag_params), do: %{"video_id" => video_id, "tags" => tag_params}

  def update_params, do: %{"tags" => valid_tag_params()}

  def valid_tag_params do
    %{
      "1" => %{"text" => "abc", "starts_at" => nil, "ends_at" => nil},
      "2" => %{"text" => "def", "starts_at" => "45", "ends_at" => "65"},
      "3" => %{"text" => "ghi", "starts_at" => nil, "ends_at" => nil}
    }
  end

  def expected_tag_info do
    [
      %{text: "abc", starts_at: nil, ends_at: nil},
      %{text: "def", starts_at: "0:45", ends_at: "1:05"},
      %{text: "ghi", starts_at: nil, ends_at: nil}
    ]
  end
end
