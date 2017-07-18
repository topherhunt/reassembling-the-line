defmodule CodingInterfaceTest do
  use EducateYour.IntegrationCase
  alias EducateYour.{Repo, Coding}

  hound_session()

  # See CodingControllerTest for the CRUD basics

  test "User can add and remove tags and submit coding data", %{conn: conn} do
    user  = insert :user
    video = insert :video

    navigate_to session_path(conn, :login_from_uuid, user.uuid)
    navigate_to admin_coding_path(conn, :new, video_id: video.id)
    table("location")    |> click_add_tag_link
    table("location")    |> click_add_tag_link
    table("sentiment")   |> click_add_tag_link
    table("topic")       |> click_add_tag_link
    table("topic")       |> click_add_tag_link
    table("location")    |> assert_num_tags(2)
    table("sentiment")   |> assert_num_tags(1)
    table("topic")       |> assert_num_tags(2)
    table("demographic") |> assert_num_tags(0)
    table("sentiment") |> tag_rows |> List.first |> click_remove_tag_link
    table("sentiment") |> assert_num_tags(0)
    table("location")  |> tag_rows |> List.first |> text_field |> fill_field("Georgia")
    table("location")  |> tag_rows |> List.last  |> text_field |> fill_field("Alabama")
    # The second "topic" tag is left blank and should be discarded on submission.
    tag_4_row = table("topic") |> tag_rows |> List.first
    tag_4_row |> text_field       |> fill_field("bullying")
    tag_4_row |> start_time_field |> fill_field("0:15")
    tag_4_row |> end_time_field   |> fill_field("0:45")
    find_element(:css, ".test-create-coding") |> click

    assert current_path() == admin_video_path(conn, :index)
    coding = video
      |> assoc(:coding)
      |> Repo.first
      |> Repo.preload([:taggings, :tags])
    tags = Coding.compact_tag_info(coding) |> Enum.sort
    assert tags == [
      %{context: "location", text: "Alabama", starts_at: nil, ends_at: nil},
      %{context: "location", text: "Georgia", starts_at: nil, ends_at: nil},
      %{context: "topic", text: "bullying", starts_at: "0:15", ends_at: "0:45"}
    ]
  end

  test "Selected tags are autopopulated when re-coding a video", %{conn: conn} do
    user   = insert :user
    coding = insert :coding
    Coding.associate_tags(coding, [
      %{"context"=>"location", "text"=>"abc"},
      %{"context"=>"sentiment", "text"=>"def", "starts_at"=>"15", "ends_at"=>"49"},
      %{"context"=>"sentiment", "text"=>"ghi", "starts_at"=>"40", "ends_at"=>"72"}
    ])
    assert (coding |> assoc(:taggings) |> Repo.count) == 3

    navigate_to session_path(conn, :login_from_uuid, user.uuid)
    navigate_to admin_coding_path(conn, :edit, coding.id)
    table("location")    |> assert_num_tags(1)
    table("sentiment")   |> assert_num_tags(2)
    table("topic")       |> assert_num_tags(0)
    table("demographic") |> assert_num_tags(0)
  end

  ##
  # DOM selection helpers
  #

  defp table(context) do
    find_all_elements(:css, ".test-tags-table")
      |> Enum.find(fn(el) -> attribute_value(el, "data-context") == context end)
      || raise("Can't find table with context #{context}!")
  end

  defp tag_rows(table) do
    table |> find_all_within_element(:css, ".test-tag-row")
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
  # Assertion helpers
  #

  defp assert_num_tags(table, expected_count) do
    assert (table |> tag_rows |> Enum.count) == expected_count
  end

  ##
  # Action helpers
  #

  defp click_add_tag_link(table) do
    table |> find_within_element(:css, ".test-add-tag") |> click
  end

  defp click_remove_tag_link(tag_row) do
    tag_row |> find_within_element(:css, ".test-remove-tag") |> click
  end

end
