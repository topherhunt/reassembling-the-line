defmodule RTLWeb.Manage.CodingControllerTest do
  use RTLWeb.ConnCase, async: true
  alias RTL.{Projects, Videos}

  describe "plugs" do
    test "all actions reject if not project admin", %{conn: conn} do
      {conn, _user} = login_as_new_user(conn)
      {proj, _, vid} = insert_project_prompt_video()

      conn = get(conn, Routes.manage_video_coding_path(conn, :new, proj, vid))

      assert redirected_to(conn) == Routes.home_path(conn, :index)
      assert conn.halted
    end

    test "all actions reject if not logged in", %{conn: conn} do
      {proj, _, vid} = insert_project_prompt_video()

      conn = get(conn, Routes.manage_video_coding_path(conn, :new, proj, vid))

      assert redirected_to(conn) == Routes.home_path(conn, :index)
      assert conn.halted
    end
  end

  describe "#new" do
    test "renders correctly", %{conn: conn} do
      {conn, user} = login_as_new_user(conn)
      {proj, _, vid} = insert_project_prompt_video(admin: user)

      conn = get(conn, Routes.manage_video_coding_path(conn, :new, proj, vid))

      assert conn.resp_body =~ "test-page-new-coding"
    end

    test "raises exception if video is not found", %{conn: conn} do
      {conn, user} = login_as_new_user(conn)
      {proj, _, _vid} = insert_project_prompt_video(admin: user)

      assert_raise(Ecto.NoResultsError, fn ->
        get(conn, Routes.manage_video_coding_path(conn, :new, proj, "999"))
      end)
    end
  end

  describe "#create" do
    test "saves my codes and redirects to the next video", %{conn: conn} do
      {conn, user} = login_as_new_user(conn)
      {proj, _, v1} = insert_project_prompt_video(admin: user)
      v2 = Factory.insert_video()

      params = %{"coding" => create_params()}
      conn = post(conn, Routes.manage_video_coding_path(conn, :create, proj, v1), params)

      assert redirected_to(conn) == Routes.manage_video_coding_path(conn, :new, proj, v2)
      coding = Videos.get_coding_by!(video_id: v1.id) |> Videos.get_coding_preloads()
      assert Videos.summarize_taggings(coding.taggings) == expected_tag_info()
    end

    test "raises exception if video is already coded", %{conn: conn} do
      {conn, user} = login_as_new_user(conn)
      {proj, _, vid} = insert_project_prompt_video(admin: user)
      Factory.insert_coding(video_id: vid.id)

      assert_raise(Ecto.InvalidChangesetError, fn ->
        params = %{"coding" => create_params()}
        post(conn, Routes.manage_video_coding_path(conn, :create, proj, vid), params)
      end)
    end

    test "raises exception if video_id is invalid", %{conn: conn} do
      {conn, user} = login_as_new_user(conn)
      {proj, _, _vid} = insert_project_prompt_video(admin: user)

      assert_raise(Ecto.NoResultsError, fn ->
        params = %{"coding" => create_params()}
        post(conn, Routes.manage_video_coding_path(conn, :create, proj, 999), params)
      end)
    end

    test "rejects changes if tags are invalid", %{conn: conn} do
      {conn, user} = login_as_new_user(conn)
      {proj, _, vid} = insert_project_prompt_video(admin: user)

      params = %{"coding" => create_params(%{"1" => %{"text" => "Topher's"}})}
      conn = post(conn, Routes.manage_video_coding_path(conn, :create, proj, vid), params)

      assert conn.resp_body =~ "Tags can only contain letters, numbers, and spaces."
    end
  end

  describe "#edit" do
    test "renders correctly", %{conn: conn} do
      {conn, user} = login_as_new_user(conn)
      {proj, _, vid} = insert_project_prompt_video(admin: user)
      coding = Factory.insert_coding(video_id: vid.id)

      conn = get(conn, Routes.manage_video_coding_path(conn, :edit, proj, vid, coding))
      assert conn.resp_body =~ "test-page-code-video-#{vid.id}"
    end
  end

  describe "#update" do
    test "saves my codes and redirects to the videos list", %{conn: conn} do
      {conn, user} = login_as_new_user(conn)
      {proj, _, vid} = insert_project_prompt_video(admin: user)
      coding = Factory.insert_coding(video_id: vid.id, tags: [%{"text" => "old_tag"}])

      update_path = Routes.manage_video_coding_path(conn, :update, proj, vid, coding)
      conn = patch(conn, update_path, %{"coding" => update_params()})

      assert redirected_to(conn) == Routes.manage_video_path(conn, :index, proj)
      reloaded_coding = Videos.get_coding!(coding.id) |> Videos.get_coding_preloads()
      assert Videos.summarize_taggings(reloaded_coding.taggings) == expected_tag_info()
    end

    test "rejects changes if tags are invalid", %{conn: conn} do
      {conn, user} = login_as_new_user(conn)
      {proj, _, vid} = insert_project_prompt_video(admin: user)
      coding = Factory.insert_coding(video_id: vid.id, tags: [%{"text" => "old1"}])

      update_path = Routes.manage_video_coding_path(conn, :update, proj, vid, coding)
      conn = patch(conn, update_path, %{"coding" => %{"tags" => invalid_tag_params()}})

      assert conn.resp_body =~ "Tags can only contain letters, numbers, and spaces."
      reloaded_coding = Videos.get_coding!(coding.id) |> Videos.get_coding_preloads()
      assert length(reloaded_coding.taggings) == 1
    end
  end

  ##
  # Helpers
  #

  defp insert_project_prompt_video(opts \\ []) do
    project = Factory.insert_project()
    prompt = Factory.insert_prompt(project_id: project.id)
    video = Factory.insert_video(prompt_id: prompt.id)
    if opts[:admin], do: Projects.add_project_admin!(opts[:admin], project)
    {project, prompt, video}
  end

  def create_params(), do: %{"tags" => valid_tag_params()}

  def create_params(tag_params), do: %{"tags" => tag_params}

  def update_params, do: %{"tags" => valid_tag_params()}

  def valid_tag_params do
    %{
      "1" => %{"text" => "abc", "starts_at" => nil, "ends_at" => nil},
      "2" => %{"text" => "def", "starts_at" => "45", "ends_at" => "65"},
      "3" => %{"text" => "ghi", "starts_at" => nil, "ends_at" => nil}
    }
  end

  def invalid_tag_params do
    %{
      "1" => %{"text" => "No apostrophe's allowed", "starts_at" => "10", "ends_at" => "30"}
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
