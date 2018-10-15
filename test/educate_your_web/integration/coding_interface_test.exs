defmodule RTLWeb.CodingInterfaceTest do
  use RTLWeb.IntegrationCase
  alias RTL.Videos
  require IEx

  hound_session()

  # See CodingControllerTest for the CRUD basics

  test "User can add and remove tags and submit coding data", %{conn: conn} do
    user  = Factory.insert_user
    video = Factory.insert_video

    navigate_to session_path(conn, :login_from_uuid, user.uuid)
    navigate_to admin_coding_path(conn, :new, video_id: video.id)

    click_add_tag_link()
    click_add_tag_link()
    click_add_tag_link()
    click_add_tag_link()
    click_add_tag_link()
    assert Enum.count(tag_rows()) == 5
    tag_rows() |> List.first |> click_remove_tag_link
    assert Enum.count(tag_rows()) == 4
    [row1, _row2, row3, row4] = tag_rows()
    row1 |> text_field |> fill_field("Georgia")
    # Don't enter anything into row2. It should be skipped on submit.
    row3 |> text_field |> fill_field("bullying")
    row3 |> start_time_field |> fill_field("0:15")
    row3 |> end_time_field |> fill_field("0:45")
    row4 |> text_field |> fill_field("Alabama")
    find_element(:css, ".test-create-coding") |> click

    assert current_path() == admin_video_path(conn, :index)
    coding = Videos.get_coding_by!(video_id: video.id) |> Videos.get_coding_preloads
    tags = Videos.summarize_taggings(coding.taggings) |> Enum.sort
    assert tags == [
      %{text: "Alabama", starts_at: nil, ends_at: nil},
      %{text: "Georgia", starts_at: nil, ends_at: nil},
      %{text: "bullying", starts_at: "0:15", ends_at: "0:45"}
    ]
  end

  test "Selected tags are autopopulated when re-coding a video", %{conn: conn} do
    user   = Factory.insert_user
    coding = Factory.insert_coding(tags: [
      %{"text"=>"abc"},
      %{"text"=>"def", "starts_at"=>"15", "ends_at"=>"49"},
      %{"text"=>"ghi", "starts_at"=>"40", "ends_at"=>"72"}
    ])

    navigate_to session_path(conn, :login_from_uuid, user.uuid)
    navigate_to admin_coding_path(conn, :edit, coding.id)
    assert Enum.count(tag_rows()) == 3
  end

  ##
  # DOM selection helpers
  #

  defp tag_rows do
    find_all_elements(:css, ".test-tag-row")
  end

  defp text_field(tag_row) do
    tag_row |> find_within_element(:css, ".test-tag-text-field")
  end

  defp start_time_field(tag_row) do
    tag_row |> find_all_within_element(:css, ".test-tag-time-field") |> List.first
  end

  defp end_time_field(tag_row) do
    tag_row |> find_all_within_element(:css, ".test-tag-time-field") |> List.last
  end

  ##
  # Action helpers
  #

  defp click_add_tag_link do
    find_element(:css, ".test-add-tag") |> click
  end

  defp click_remove_tag_link(tag_row) do
    tag_row |> find_within_element(:css, ".test-remove-tag") |> click
  end

end
