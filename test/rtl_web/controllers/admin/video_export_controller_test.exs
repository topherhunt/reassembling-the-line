defmodule RTLWeb.Admin.VideoExportControllerTest do
  use RTLWeb.ConnCase, async: true

  test "all actions require project admin", %{conn: conn} do
    project = Factory.insert_project()
    conn = get(conn, Routes.admin_video_export_path(conn, :new, project))

    assert redirected_to(conn) == Routes.auth_path(conn, :login)
    assert conn.halted
  end

  describe "#new" do
    test "renders correctly", %{conn: conn} do
      {conn, user} = login_as_new_user(conn)
      project = Factory.insert_project()
      prompt = Factory.insert_prompt(project_id: project.id)
      video = Factory.insert_video(prompt_id: prompt.id)
      RTL.Projects.add_project_admin!(user, project)

      conn = get(conn, Routes.admin_video_export_path(conn, :new, project))

      assert conn.resp_body =~ "test-page-manage-video-export-new"
      assert conn.resp_body =~ video.speaker_name
      assert conn.resp_body =~ video.recording_filename
    end
  end
end
