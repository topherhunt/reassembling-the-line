# High-level coverage of the manage videos & coding UI, including the videos list LV.
# See CodingControllerTest for the CRUD basics.

defmodule RTLWeb.CodingInterfaceTest do
  use RTLWeb.IntegrationCase
  alias RTL.{Projects, Videos}

  hound_session()

  test "User can list and delete videos (LiveView)", %{conn: conn} do
    user = Factory.insert_user()
    project = Factory.insert_project()
    prompt = Factory.insert_prompt(project_id: project.id)
    v1 = Factory.insert_video(prompt_id: prompt.id)
    v2 = Factory.insert_video(prompt_id: prompt.id)
    Projects.add_project_admin!(user, project)

    login(conn, user)
    navigate_to Routes.manage_video_path(conn, :index, project)
    assert_selector(".test-row-video-#{v1.id}")
    assert_selector(".test-row-video-#{v2.id}")

    # This is a LV phx-click event.
    find_element(".test-link-delete-video-#{v1.id}") |> click()
    accept_dialog()

    wait_until(fn -> count_selector(".test-row-video-#{v1.id}") == 0 end)
    refute_selector(".test-row-video-#{v1.id}")
    assert_selector(".test-row-video-#{v2.id}")
  end

  test "User can code a video", %{conn: conn} do
    user = Factory.insert_user()
    project = Factory.insert_project()
    prompt = Factory.insert_prompt(project_id: project.id)
    video = Factory.insert_video(prompt_id: prompt.id)
    Projects.add_project_admin!(user, project)

    login(conn, user)
    navigate_to Routes.manage_video_path(conn, :index, project)
    find_element(".test-link-code-video-#{video.id}") |> click()

    click_add_tag_link()
    click_add_tag_link()
    click_add_tag_link()
    click_add_tag_link()
    click_add_tag_link()
    assert length(tag_rows()) == 5
    tag_rows() |> List.first() |> click_remove_tag_link
    assert length(tag_rows()) == 4
    [row1, _row2, row3, row4] = tag_rows()
    row1 |> text_field |> fill_field("Georgia")
    # Don't enter anything into row2. It should be skipped on submit.
    row3 |> text_field |> fill_field("bullying")
    row3 |> start_time_field |> fill_field("0:15")
    row3 |> end_time_field |> fill_field("0:45")
    row4 |> text_field |> fill_field("Alabama")
    find_element(".test-create-coding") |> click

    assert current_path() == Routes.manage_video_path(conn, :index, project)
    coding = Videos.get_coding_by!(video_id: video.id) |> Videos.get_coding_preloads()
    tags = Videos.summarize_taggings(coding.taggings) |> Enum.sort()

    expected = [
      %{text: "Alabama", starts_at: nil, ends_at: nil},
      %{text: "Georgia", starts_at: nil, ends_at: nil},
      %{text: "bullying", starts_at: "0:15", ends_at: "0:45"}
    ]

    assert tags == expected
  end

  test "Selected tags are autopopulated when re-coding a video", %{conn: conn} do
    user = Factory.insert_user()
    project = Factory.insert_project()
    prompt = Factory.insert_prompt(project_id: project.id)
    video = Factory.insert_video(prompt_id: prompt.id)
    Projects.add_project_admin!(user, project)

    tag_attrs = [
      %{"text" => "abc"},
      %{"text" => "def", "starts_at" => "15", "ends_at" => "49"},
      %{"text" => "ghi", "starts_at" => "40", "ends_at" => "72"}
    ]

    coding = Factory.insert_coding(video_id: video.id, tags: tag_attrs)

    login(conn, user)
    navigate_to(Routes.manage_video_coding_path(conn, :edit, project, video, coding))
    assert length(tag_rows()) == 3
  end

  #
  # DOM selection helpers
  #

  defp tag_rows do
    find_all_elements(".test-tag-row")
  end

  defp text_field(tag_row) do
    tag_row |> find_within_element(".test-tag-text-field")
  end

  defp start_time_field(tag_row) do
    tag_row |> find_within_element(".js-start-time-field")
  end

  defp end_time_field(tag_row) do
    tag_row |> find_within_element(".js-end-time-field")
  end

  #
  # Action helpers
  #

  defp login(conn, user) do
    navigate_to Routes.auth_path(conn, :force_login, user.uuid)
  end

  defp click_add_tag_link do
    find_element(".test-add-tag") |> click()
  end

  defp click_remove_tag_link(tag_row) do
    tag_row |> find_within_element(".test-remove-tag") |> click
  end
end
