defmodule RTLWeb.Admin.VideoControllerTest do
  use RTLWeb.ConnCase, async: true
  alias RTL.Videos

  describe "all actions" do
    test "reject if not logged in", %{conn: conn} do
      conn = get(conn, Routes.admin_video_path(conn, :index, "1"))

      assert redirected_to(conn) == Routes.auth_path(conn, :login)
      assert conn.halted
    end

    test "reject if not an admin of this project", %{conn: conn} do
      {conn, _user} = login_as_new_user(conn)
      project = insert_project()

      conn = get(conn, Routes.admin_video_path(conn, :index, project))
      assert redirected_to(conn) == Routes.home_path(conn, :index)
      assert conn.halted
    end

    test "allow if superadmin", %{conn: conn} do
      {conn, _user} = login_as_superadmin(conn)
      project = insert_project()

      conn = get(conn, Routes.admin_video_path(conn, :index, project))
      assert html_response(conn, 200) =~ "test-page-manage-video-index"
    end
  end

  describe "#index" do
    test "renders correctly", %{conn: conn} do
      {conn, user} = login_as_new_user(conn)
      project = insert_project()
      prompt = insert_prompt(project_id: project.id)
      _v1 = insert_video(prompt_id: prompt.id)
      _v2 = insert_video(prompt_id: prompt.id)
      RTL.Projects.add_project_admin!(user, project)

      conn = get(conn, Routes.admin_video_path(conn, :index, project))

      assert html_response(conn, 200) =~ "test-page-manage-video-index"
    end
  end

  describe "#code" do
    test "renders the coding page", %{conn: conn} do
      {conn, user} = login_as_new_user(conn)
      project = insert_project()
      prompt = insert_prompt(project_id: project.id)
      video = insert_video(prompt_id: prompt.id)
      RTL.Projects.add_project_admin!(user, project)

      conn = get(conn, Routes.admin_video_path(conn, :code, project, video))

      assert html_response(conn, 200) =~ "test-page-code-video-#{video.id}"
    end
  end

  describe "#mark_coded" do
    test "marks this coding as completed by this coder", %{conn: conn} do
      {conn, user} = login_as_new_user(conn)
      project = insert_project()
      prompt = insert_prompt(project_id: project.id)
      video = insert_video(prompt_id: prompt.id)
      coding = insert_coding(video_id: video.id, completed_at: nil)
      RTL.Projects.add_project_admin!(user, project)

      assert Videos.get_coding(coding.id).completed_at == nil

      conn = post(conn, Routes.admin_video_path(conn, :mark_coded, project, video))

      assert Videos.get_coding(coding.id).completed_at != nil
      assert redirected_to(conn) == Routes.admin_video_path(conn, :index, project)
    end
  end
end
