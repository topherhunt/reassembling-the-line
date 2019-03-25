defmodule RTLWeb.Admin.VideoControllerTest do
  use RTLWeb.ConnCase, async: true
  alias RTL.Videos

  test "all actions require logged-in user", %{conn: conn} do
    [
      get(conn, admin_video_path(conn, :index)),
      get(conn, admin_video_path(conn, :delete, "1")),
    ]
    |> Enum.each(fn conn ->
      assert redirected_to(conn) == home_path(conn, :index)
      assert conn.halted
    end)
  end

  describe "#index" do
    test "renders correctly", %{conn: conn} do
      {conn, _user} = login_as_new_user(conn)
      # Populate some dummy data
      # TODO: Add coding data to a video so it's more realistic
      Factory.insert_video()
      Factory.insert_video()

      conn = get(conn, admin_video_path(conn, :index))

      assert html_response(conn, 200) =~ "Code videos"
    end

    test "renders correctly when no videos", %{conn: conn} do
      {conn, _user} = login_as_new_user(conn)

      conn = get(conn, admin_video_path(conn, :index))

      assert html_response(conn, 200) =~ "Code videos"
    end
  end

  describe "#delete" do
    test "deletes the video and redirects", %{conn: conn} do
      {conn, _user} = login_as_new_user(conn)
      video = Factory.insert_video()
      coding = Factory.insert_coding(video_id: video.id)

      conn = get(conn, admin_video_path(conn, :delete, video.id))

      assert redirected_to(conn) == admin_video_path(conn, :index)
      assert Videos.get_video(video.id) == nil
      assert Videos.get_coding(coding.id) == nil
    end
  end
end
