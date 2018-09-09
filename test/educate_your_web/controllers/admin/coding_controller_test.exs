defmodule EducateYourWeb.Admin.CodingControllerTest do
  use EducateYourWeb.ConnCase, async: true
  alias EducateYour.Schemas.{Coding, Tagging}

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
    video = insert :video

    conn = get(conn, admin_coding_path(conn, :new, video_id: video.id))
    assert html_response(conn, 200) =~ "Coding video: \"#{video.title}\""
  end

  test "#new raises exception if video is not found", %{conn: conn} do
    {conn, _} = login_as_new_user(conn)
    insert :video

    assert_raise(Ecto.NoResultsError, fn()->
      get(conn, admin_coding_path(conn, :new, video_id: "99999"))
    end)
  end

  test "#create saves my codes and redirects to the next video", %{conn: conn} do
    {conn, _} = login_as_new_user(conn)
    video1 = insert :video
    video2 = insert :video
    assert Repo.count(Coding) == 0

    conn = post(conn, admin_coding_path(conn, :create),
      coding: create_params(video1))
    assert redirected_to(conn) == admin_coding_path(conn, :new, video_id: video2.id)
    assert Repo.count(Coding) == 1
    coding = Repo.first(Coding) |> Repo.preload(taggings: :tag)
    assert coding.video_id == video1.id
    assert Coding.compact_tag_info(coding) == expected_tag_info()
  end

  test "#create raises exception video is already coded", %{conn: conn} do
    {conn, _} = login_as_new_user(conn)
    other_coding = insert :coding
    assert Repo.count(Coding) == 1

    assert_raise(Ecto.InvalidChangesetError, fn()->
      post(conn, admin_coding_path(conn, :create),
        coding: create_params(other_coding.video))
    end)
    assert Repo.count(Coding) == 1 # not changed
  end

  test "#create raises exception if video id is invalid", %{conn: conn} do
    {conn, _} = login_as_new_user(conn)
    insert :video

    assert_raise(Ecto.ConstraintError, fn()->
      post(conn, admin_coding_path(conn, :create), coding: %{video_id: "999999", tags: %{}})
    end)
    assert Repo.count(Coding) == 0
  end

  test "#create rejects changes if tags are invalid", %{conn: conn} do
    {conn, _} = login_as_new_user(conn)
    video = insert :video

    coding_params = %{video_id: video.id, tags: %{"1" => %{"text" => "Topher's"}}}
    conn = post(conn, admin_coding_path(conn, :create), coding: coding_params)
    assert Repo.count(Coding) == 0
    assert html_response(conn, 200) =~ "Unable to save your changes because tags must only contain letters, numbers, and spaces."
  end

  test "#edit renders correctly", %{conn: conn} do
    {conn, _} = login_as_new_user(conn)
    coding = insert :coding

    conn = get(conn, admin_coding_path(conn, :edit, coding.id))
    assert html_response(conn, 200) =~ "Coding video: \"#{coding.video.title}\""
  end

  test "#update saves my codes and redirects to the videos list", %{conn: conn} do
    {conn, _} = login_as_new_user(conn)
    coding = insert :coding
    Coding.associate_tags(coding, [
      %{"text" => "abc"},
      %{"text" => "def", "starts_at" => "15", "ends_at" => "49"},
      %{"text" => "ghi", "starts_at" => "40", "ends_at" => "72"}
    ])
    assert (coding |> assoc(:taggings) |> Repo.count) == 3

    conn = patch(conn, admin_coding_path(conn, :update, coding.id),
      coding: update_params())
    assert redirected_to(conn) == admin_video_path(conn, :index)
    latest_coding = Repo.get!(Coding, coding.id) |> Repo.preload(taggings: :tag)
    assert Coding.compact_tag_info(latest_coding) == expected_tag_info()
  end

  test "#update rejects changes if tags are invalid", %{conn: conn} do
    {conn, _} = login_as_new_user(conn)
    coding = insert :coding
    Coding.associate_tags(coding, [
      %{"text" => "abc"},
      %{"text" => "def"},
    ])

    coding_params = %{tags: %{"1" => %{"text" => "Topher's"}}}
    conn = patch(conn, admin_coding_path(conn, :update, coding.id), coding: coding_params)

    assert (Tagging |> where([t], t.coding_id == ^coding.id) |> Repo.count()) == 2
    assert html_response(conn, 200) =~ "Unable to save your changes because tags must only contain letters, numbers, and spaces."
  end

  ##
  # Helpers
  #

  def create_params(video) do
    update_params() |> Map.merge(%{"video_id" => video.id})
  end

  def update_params do
    %{
      "tags" => %{
        "1" => %{"text" => "abc", "starts_at" => nil, "ends_at" => nil},
        "2" => %{"text" => "def", "starts_at" => nil, "ends_at" => nil},
        "3" => %{"text" => "ghi", "starts_at" => nil, "ends_at" => nil},
        "4" => %{"text" => "jkl", "starts_at" => nil, "ends_at" => nil}
      }
    }
  end

  def expected_tag_info do
    [
      %{ends_at: nil, starts_at: nil, text: "abc"},
      %{ends_at: nil, starts_at: nil, text: "def"},
      %{ends_at: nil, starts_at: nil, text: "ghi"},
      %{ends_at: nil, starts_at: nil, text: "jkl"}
    ]
  end
end
