defmodule RTLWeb.Manage.VideosListLiveviewTest do
  use RTL.DataCase

  # Docs: https://github.com/phoenixframework/phoenix_live_view/blob/master/lib/phoenix_live_view/test/live_view_test.ex
  import Phoenix.LiveViewTest

  defp mount_the_view(session: session) do
    mount(RTLWeb.Endpoint, RTLWeb.Manage.VideosListLiveview, session: session)
  end

  test "renders correctly" do
    v1 = Factory.insert_video()
    v2 = insert_video_with_tags(["abc:30:60", "Def:15:49", "ghi:65:82"])

    {:ok, _view, html} = mount_the_view(session: %{})

    assert html =~ "Code videos"
    assert html =~ v1.title
    assert html =~ v2.title
  end

  test "renders correctly when no videos" do
    {:ok, _view, html} = mount_the_view(session: %{})

    assert html =~ "Code videos"
  end

  test "delete_video works" do
    v1 = Factory.insert_video()
    v2 = Factory.insert_video()

    {:ok, view, _html} = mount_the_view(session: %{})
    html = render_click(view, :delete_video, v1.id)

    # The video is deleted
    assert RTL.Videos.get_video(v1.id) == nil
    assert RTL.Videos.get_video(v2.id) != nil
    # But the view doesn't rerender yet
    assert html =~ v1.title
    assert html =~ v2.title

    # Once the LV gets the notification about updated data, it re-renders
    send(view.pid, {RTL.Videos, "unimportant_message_string"})
    html = render(view)
    assert !(html =~ v1.title)
    assert html =~ v2.title
  end
end
