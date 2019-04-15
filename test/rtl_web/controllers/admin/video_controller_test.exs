defmodule RTLWeb.Admin.VideoControllerTest do
  use RTLWeb.ConnCase, async: true

  test "all actions require logged-in user", %{conn: conn} do
    [
      get(conn, Routes.admin_video_path(conn, :index))
    ]
    |> Enum.each(fn conn ->
      assert redirected_to(conn) == Routes.home_path(conn, :index)
      assert conn.halted
    end)
  end

  describe "#index" do
    test "renders correctly", %{conn: conn} do
      {conn, _user} = login_as_new_user(conn)

      conn = get(conn, Routes.admin_video_path(conn, :index))

      # This is a Liveview so we won't test it any further.
      assert html_response(conn, 200) =~ "Code videos"
    end
  end

  # describe "#delete" do
  #   test "deletes the video and redirects", %{conn: conn} do
  #     {conn, _user} = login_as_new_user(conn)
  #     video = Factory.insert_video()
  #     coding = Factory.insert_coding(video_id: video.id)

  #     conn = get(conn, Routes.admin_video_path(conn, :delete, video.id))

  #     assert redirected_to(conn) == Routes.admin_video_path(conn, :index)
  #     assert Videos.get_video(video.id) == nil
  #     assert Videos.get_coding(coding.id) == nil
  #   end
  # end
end
