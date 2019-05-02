defmodule RTLWeb.Manage.VideoControllerTest do
  use RTLWeb.ConnCase, async: true

  test "all actions require logged-in user", %{conn: conn} do
    [
      get(conn, Routes.manage_video_path(conn, :index, "1"))
    ]
    |> Enum.each(fn conn ->
      assert redirected_to(conn) == Routes.home_path(conn, :index)
      assert conn.halted
    end)
  end

  describe "#index" do
    test "renders correctly", %{conn: conn} do
      {conn, user} = login_as_new_user(conn)
      project = Factory.insert_project()
      RTL.Projects.add_project_admin!(user, project)

      conn = get(conn, Routes.manage_video_path(conn, :index, project))

      # This is a Liveview so we won't test it any further.
      assert html_response(conn, 200) =~ "test-page-list-videos"
    end

    test "rejects non-admin", %{conn: conn} do
      {conn, _user} = login_as_new_user(conn)
      project = Factory.insert_project()

      conn = get(conn, Routes.manage_video_path(conn, :index, project))

      assert redirected_to(conn) == Routes.home_path(conn, :index)
    end
  end
end
