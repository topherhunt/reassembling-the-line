defmodule RTLWeb.Admin.CodingControllerTest do
  use RTLWeb.ConnCase, async: true
  alias RTL.Videos

  test "all actions require logged-in user", %{conn: conn} do
    [
      get(conn, admin_coding_path(conn, :new)),
      post(conn, admin_coding_path(conn, :create)),
      get(conn, admin_coding_path(conn, :edit, "123")),
      patch(conn, admin_coding_path(conn, :update, "123"))
    ] |> Enum.each(fn(conn) ->
      assert redirected_to(conn) == home_path(conn, :index)
      assert conn.halted
    end)
  end

  test "#new renders correctly", %{conn: conn} do
    {conn, _} = login_as_new_user(conn)
    video = Factory.insert_video

    conn = get(conn, admin_coding_path(conn, :new, video_id: video.id))
    assert html_response(conn, 200) =~ "Coding video: \"#{video.title}\""
  end

  test "#new raises exception if video is not found", %{conn: conn} do
    {conn, _} = login_as_new_user(conn)
    Factory.insert_video

    assert_raise(Ecto.NoResultsError, fn()->
      get(conn, admin_coding_path(conn, :new, video_id: "99999"))
    end)
  end

  test "#create saves my codes and redirects to the next video", %{conn: conn} do
    {conn, _} = login_as_new_user(conn)
    v1 = Factory.insert_video
    v2 = Factory.insert_video

    conn = post(conn, admin_coding_path(conn, :create), coding: create_params(v1.id))
    assert redirected_to(conn) == admin_coding_path(conn, :new, video_id: v2.id)
    coding = Videos.get_coding_by!(video_id: v1.id) |> Videos.get_coding_preloads
    assert Videos.summarize_taggings(coding.taggings) == expected_tag_info()
  end

  test "#create raises exception if video is already coded", %{conn: conn} do
    {conn, _} = login_as_new_user(conn)
    video = Factory.insert_video
    Factory.insert_coding(video_id: video.id)

    assert_raise(Ecto.InvalidChangesetError, fn()->
      post(conn, admin_coding_path(conn, :create), coding: create_params(video.id))
    end)
  end

  test "#create raises exception if video_id is invalid", %{conn: conn} do
    {conn, _} = login_as_new_user(conn)
    Factory.insert_video

    assert_raise(Ecto.ConstraintError, fn()->
      post(conn, admin_coding_path(conn, :create), coding: create_params("99999"))
    end)
  end

  test "#create rejects changes if tags are invalid", %{conn: conn} do
    {conn, _} = login_as_new_user(conn)
    video = Factory.insert_video

    conn = post(conn, admin_coding_path(conn, :create),
        coding: create_params(video.id, %{"1" => %{"text" => "Topher's"}}))
    assert html_response(conn, 200) =~ "Unable to save your changes because tags must only contain letters, numbers, and spaces."
  end

  test "#edit renders correctly", %{conn: conn} do
    {conn, _} = login_as_new_user(conn)
    coding = Factory.insert_coding
    video = Videos.get_video!(coding.video_id)

    conn = get(conn, admin_coding_path(conn, :edit, coding.id))
    assert html_response(conn, 200) =~ "Coding video: \"#{video.title}\""
  end

  test "#update saves my codes and redirects to the videos list", %{conn: conn} do
    {conn, _} = login_as_new_user(conn)
    coding = Factory.insert_coding(tags: [%{"text"=>"old_tag"}])

    conn = patch(conn, admin_coding_path(conn, :update, coding.id), coding: update_params())
    assert redirected_to(conn) == admin_video_path(conn, :index)
    reloaded_coding = Videos.get_coding!(coding.id) |> Videos.get_coding_preloads
    assert Videos.summarize_taggings(reloaded_coding.taggings) == expected_tag_info()
  end

  test "#update rejects changes if tags are invalid", %{conn: conn} do
    {conn, _} = login_as_new_user(conn)
    coding = Factory.insert_coding(tags: [%{"text"=>"old1"}, %{"text"=>"old2"}])

    conn = patch(conn, admin_coding_path(conn, :update, coding.id),
      coding: %{"tags"=>%{"1"=>%{"text"=>"Topher's"}}})
    assert html_response(conn, 200) =~ "Unable to save your changes because tags must only contain letters, numbers, and spaces."
    reloaded_coding = Videos.get_coding!(coding.id) |> Videos.get_coding_preloads
    assert length(reloaded_coding.taggings) == 2
  end

  ##
  # Helpers
  #

  def create_params(video_id), do: %{"video_id"=>video_id, "tags"=>valid_tag_params()}
  def create_params(video_id, tag_params), do: %{"video_id"=>video_id, "tags"=>tag_params}
  def update_params, do: %{"tags" => valid_tag_params()}

  def valid_tag_params do
    %{"1"=>%{"text"=>"abc", "starts_at"=>nil, "ends_at"=>nil},
      "2"=>%{"text"=>"def", "starts_at"=>45,  "ends_at"=>65},
      "3"=>%{"text"=>"ghi", "starts_at"=>nil, "ends_at"=>nil}}
  end

  def expected_tag_info do
    [
      %{text: "abc", starts_at: nil, ends_at: nil},
      %{text: "def", starts_at: "0:45",  ends_at: "1:05"},
      %{text: "ghi", starts_at: nil, ends_at: nil}
    ]
  end
end
