defmodule RTLWeb.Admin.VideoImportControllerTest do
  use RTLWeb.ConnCase, async: true

  test "all actions require project admin", %{conn: conn} do
    project = Factory.insert_project()
    conn = get(conn, Routes.admin_video_import_path(conn, :new, project))

    assert redirected_to(conn) == Routes.home_path(conn, :index)
    assert conn.halted
  end

  describe "#new" do
    test "renders correctly", %{conn: conn} do
      {conn, user} = login_as_new_user(conn)
      project = Factory.insert_project()
      RTL.Projects.add_project_admin!(user, project)

      conn = get(conn, Routes.admin_video_import_path(conn, :new, project))

      assert conn.resp_body =~ "test-page-manage-video-import-new"
    end
  end

  describe "#create" do
    test "imports the videos", %{conn: conn} do
      {conn, user} = login_as_new_user(conn)
      project = Factory.insert_project()
      prompt = Factory.insert_prompt(project_id: project.id)
      Factory.insert_video(prompt_id: prompt.id)
      RTL.Projects.add_project_admin!(user, project)
      assert RTL.Videos.count_videos(project: project) == 1

      params = %{"prompt_id" => prompt.id, "videos_json" => stub_videos_json()}
      conn = post(conn, Routes.admin_video_import_path(conn, :create, project), params)

      assert RTL.Videos.count_videos(project: project) == 4
      assert redirected_to(conn) == Routes.admin_project_path(conn, :show, project)
    end

    defp stub_videos_json, do: ~s([
      {"recording_filename":"video1.webm","source_url":"youtube.com/1","thumbnail_filename":"thumb1.jpg","title":"Computer science"},
      {"recording_filename":"video2.webm","source_url":"youtube.com/2","thumbnail_filename":"thumb2.jpg","title":"Pride standing in the way of progress"},
      {"recording_filename":"video3.webm","source_url":"youtube.com/3","thumbnail_filename":"thumb3.jpg","title":"Core values"}
    ])
  end
end
