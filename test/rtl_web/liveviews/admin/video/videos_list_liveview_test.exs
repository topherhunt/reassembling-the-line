defmodule RTLWeb.Admin.VideosListLiveviewTest do
  use RTL.DataCase

  # Docs: https://github.com/phoenixframework/phoenix_live_view/blob/master/lib/phoenix_live_view/test/live_view_test.ex
  import Phoenix.LiveViewTest

  defp mount_the_view(session: session) do
    mount(RTLWeb.Endpoint, RTLWeb.Admin.VideosListLiveview, session: session)
  end

  test "renders correctly" do
    user = Factory.insert_user()
    project = Factory.insert_project()
    prompt = Factory.insert_prompt(project_id: project.id)
    # Insert some videos: 1 uncoded, 1 coded, and 1 irrelevant (will be excluded)
    v1 = Factory.insert_video(prompt_id: prompt.id)
    v2 = Factory.insert_video(prompt_id: prompt.id, coded_with_tags: [{"abc", 30, 60}])
    v3 = Factory.insert_video()

    {:ok, _view, html} = mount_the_view(session: %{current_user: user, project: project})

    assert html =~ "test-page-manage-video-index"
    assert html =~ "test-row-video-#{v1.id}"
    assert html =~ "test-row-video-#{v2.id}"
    assert !(html =~ "test-row-video-#{v3.id}")
  end

  test "renders correctly when no videos" do
    user = Factory.insert_user()
    project = Factory.insert_project()

    {:ok, _view, html} = mount_the_view(session: %{current_user: user, project: project})

    assert html =~ "test-page-manage-video-index"
  end

  test "delete_video works" do
    user = Factory.insert_user()
    project = Factory.insert_project()
    prompt = Factory.insert_prompt(project_id: project.id)
    v1 = Factory.insert_video(prompt_id: prompt.id)
    v2 = Factory.insert_video(prompt_id: prompt.id)

    {:ok, view, _html} = mount_the_view(session: %{current_user: user, project: project})
    html = render_click(view, :delete_video, v1.id)

    # The video is deleted
    assert RTL.Videos.get_video(v1.id) == nil
    assert RTL.Videos.get_video(v2.id) != nil
    # But the view doesn't rerender yet
    assert html =~ "test-row-video-#{v1.id}"
    assert html =~ "test-row-video-#{v2.id}"

    # Once the LV gets the notification about updated data, it re-renders
    send(view.pid, {RTL.Videos, "unimportant_message_string"})
    html = render(view)
    assert !(html =~ "test-row-video-#{v1.id}")
    assert html =~ "test-row-video-#{v2.id}"
  end
end
