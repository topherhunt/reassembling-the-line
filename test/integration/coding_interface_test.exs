defmodule CodingInterfaceTest do
  use EducateYour.IntegrationCase
  alias EducateYour.{Repo, Coding}
  require IEx

  hound_session()

  # See CodingControllerTest for the CRUD basics

  test "User can add and remove tags and submit coding data", %{conn: conn} do
    {conn, user} = login_as_new_user(conn)
    video = insert :video

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
    table("topic")     |> tag_rows |> List.first |> text_field |> fill_field("books")
    # The second "topic" tag is left blank and should be discarded on submission.
    tag_4_row = table("topics") |> tag_rows |> List.first
    tag_4_row |> text_field       |> fill_field("bullying")
    tag_4_row |> start_time_field |> fill_field("0:15")
    tag_4_row |> end_time_field   |> fill_field("0:45")
    find_element(".test-create-coding") |> click

    assert current_path() == "blah"
    coding = video
      |> Repo.assoc(:coding)
      |> Repo.first
      |> Repo.preload([:taggings, :tags])
    tags = Coding.compact_tag_info(coding) |> Enum.sort
    assert tags == [
      %{
        context: "location",
        text: "Alabama",
        starts_at: nil,
        ends_at: nil
      },
      %{
        context: "location",
        text: "Georgia",
        starts_at: nil,
        ends_at: nil
      },

    ]
  end

  test "Tags autocomplete", %{conn: conn} do
    {conn, user} = login_as_new_user(conn)
    video = insert :video
    insert :tag, context: "topic", text: "bullying"
    insert :tag, context: "topic", text: "teaching method"

    navigate_to admin_coding_path(conn, :new, video_id: video.id)
    table("location") |> click_add_tag_link
    table("location") |> tag_rows |> list.first |> text_field |> fill_field "tea"
    raise "TODO: assert that no autocomplete suggestions appear"
    table("topic") |> tag_rows |> list.first |> text_field |> fill_field "tea"
    raise "TODO: assert that an autocomplete suggestion appears. Click it."
    raise "TODO: assert that the tag text 'teaching method' was filled in."
  end

  test "Selected tags are autopopulated when re-coding a video", %{conn: conn} do
    {conn, user} = login_as_new_user(conn)
    coding = insert :coding
    Coding.associate_tags(coding, [
      %{"context" => "location", "text" => "abc"},
      %{"context" => "sentiment", "text" => "def", "starts_at" => 15, "ends_at" => 49},
      %{"context" => "sentinent", "text" => "ghi", "starts_at" => 40, "ends_at" => 72}
    ])
    assert (coding |> Repo.assoc(:taggings) |> Repo.count) == 3

    navigate_to admin_coding_path(conn, :edit, coding.id)
    raise "TODO: Inspect the page and verify that all tags look correct"
  end

  ##
  # DOM selection helpers
  #

  defp table(context) do
    find_element(".tags-table[data-context=\"#{context}\"]")
  end

  defp tag_rows(table) do
    table |> find_all_within_element(:css, ".test-tag-row")
  end

  def text_field(tag_row) do
    tag_row |> find_within_element(".test-tag-text-field")
  end

  defp start_time_field(tag_row) do
    tag_row |> find_all_within_element(:css, ".test-tag-time-field") |> List.first
  end

  defp end_time_field(tag_row) do
    tag_row |> find_all_within_element(".test-tag-time-field") |> List.last
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
    tag_row |> find_within_element(".test-remove-tag") |> click
  end

end
