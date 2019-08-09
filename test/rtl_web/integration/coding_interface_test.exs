# High-level coverage of the manage videos & coding UI, including the videos list LV.
# See CodingControllerTest for the CRUD basics.

defmodule RTLWeb.CodingInterfaceTest do
  use RTLWeb.IntegrationCase
  alias RTL.{Projects}
  alias RTL.Videos.{Coding, Tagging, Tag}

  hound_session()

  test "Project admin can list and delete videos", %{conn: conn} do
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

    # I can open the coding page for a video
    login(conn, user)
    navigate_to Routes.manage_video_path(conn, :index, project)
    assert_selector(".test-page-manage-video-index")
    find_element(".test-link-code-video-#{video.id}") |> click()
    assert_selector(".test-coding-page")

    # I can add, edit, and delete tags
    tag1 = create_tag(project)
    tag2 = create_tag(project)
    tag3 = create_tag(project)
    edit_tag_text(tag2, "policy")
    delete_tag(tag3)

    # I can apply tags to the timeline
    make_timeline_selection(9, 23)
    # TODO: Troubleshoot flaps here
    apply_tag(tag1)
    apply_tag(tag2)
    make_timeline_selection(44, 78)
    apply_tag(tag2)
    assert_tagging(tag1, 9, 23)
    assert_tagging(tag2, 9, 23)
    assert_tagging(tag2, 44, 78)

    Process.sleep(2000)

    # I can edit and delete taggings
    edit_tagging({tag1, 9, 23}, :starts_at, 21)
    delete_tagging(tag2, 9, 23)

    Process.sleep(2000)

    # I can mark coding as complete
    assert Coding.first!(video: video).completed_at == nil
    find_element(".test-complete-coding-button") |> click()
    assert_selector(".test-page-manage-video-index")
    assert Coding.first!(video: video).completed_at != nil

    # I can edit tags for a video
    find_element(".test-link-code-video-#{video.id}") |> click()
    assert_selector(".test-coding-page")
    refute_selector(".test-complete-coding-button")
    # All my tagging data shows up as it should
    Process.sleep(2000)
    assert_tagging(tag1, 21, 23)
    assert_tagging(tag2, 44, 78)
  end

  #
  # Helpers
  #

  defp login(conn, user) do
    navigate_to Routes.auth_path(conn, :force_login, user.uuid)
  end

  defp create_tag(project) do
    text = Factory.random_uuid()

    # sanity check: the add tag form should be in "inactive" state
    refute_selector(".test-add-tag-submit")
    find_element(".test-add-tag-field") |> fill_field(text)
    find_element(".test-add-tag-submit") |> click()

    # Ensure the form submitted
    refute_selector(".test-add-tag-submit")
    tag = Tag.first!(project: project, text: text)
    assert_selector(".test-tag-row-#{tag.id}", text: text)
    tag
  end

  defp edit_tag_text(tag, new_text) do
    row_class = ".test-tag-row-#{tag.id}"

    find_element(row_class) |> move_to(1, 1)
    # sanity check: the tag row should not be in editing state.
    refute_selector("#{row_class} .test-tag-edit-submit")
    find_element("#{row_class} .test-tag-edit-link") |> click()
    find_element("#{row_class} .test-tag-edit-field") |> fill_field(new_text)
    find_element("#{row_class} .test-tag-edit-submit") |> click()

    # Ensure the form submitted and the tag was updated
    refute_selector("#{row_class} .test-tag-edit-submit")
    assert Tag.get!(tag.id).text == new_text
  end

  defp delete_tag(tag) do
    row_class = ".test-tag-row-#{tag.id}"

    find_element(row_class) |> move_to(1, 1)
    find_element("#{row_class} .test-tag-delete-link") |> click()
    accept_dialog()

    # Ensure the tag is removed both from the list and from the db
    refute_selector(row_class)
    assert Tag.get(tag.id) == nil
  end

  defp apply_tag(tag) do
    row_class = ".test-tag-row-#{tag.id}"
    find_element(row_class) |> move_to(1, 1)
    find_element("#{row_class} .test-tag-apply-link") |> click()
    # We don't yet assert that it was applied; we don't have enough info to do that here
  end

  defp make_timeline_selection(from, to) do
    find_element(".test-tickmark-#{from}s") |> move_to(0, 0)
    mouse_down(0)
    find_element(".test-tickmark-#{to}s") |> move_to(0, 0)
    mouse_up(0)

    assert_selector(".test-timeline-selection-#{from}s-#{to}s")
  end

  defp assert_tagging(tag, from, to) do
    # Confirm that it shows up on the page
    selector = get_tagging_selector(tag.id, from, to)
    assert_selector(selector)

    # Confirm that it's persisted w correct values
    assert Tagging.first(tag: tag, starts_at: from, ends_at: to) != nil
  end

  defp edit_tagging({tag, old_starts_at, ends_at}, :starts_at, new_starts_at) do
    old_selector = get_tagging_selector(tag.id, old_starts_at, ends_at)
    find_element(old_selector) |> click()
    find_element("#{old_selector} .test-handle-left") |> move_to(1, 1)
    mouse_down(0)

    find_element(".test-tickmark-#{new_starts_at}s") |> move_to(0, 0)
    mouse_up(0)

    # Confirm that the tagging updates on the page
    new_selector = get_tagging_selector(tag.id, new_starts_at, ends_at)
    assert_selector(new_selector)
    # Confirm that the tagging is updated in the db
    assert Tagging.first(tag: tag, starts_at: new_starts_at, ends_at: ends_at) != nil
  end

  defp delete_tagging(tag, from, to) do
    selector = get_tagging_selector(tag.id, from, to)
    find_element(selector) |> click()
    find_element("#{selector} .test-tagging-delete-link") |> click()
    accept_dialog()

    refute_selector(selector)
    assert Tagging.first(tag: tag, starts_at: from, ends_at: to) == nil
  end

  defp get_tagging_selector(tag_id, from, to) do
    ".test-tagging"<>
    "[data-tag-id=\"#{tag_id}\"]"<>
    "[data-starts-at=\"#{from}\"]"<>
    "[data-ends-at=\"#{to}\"]"
  end
end
