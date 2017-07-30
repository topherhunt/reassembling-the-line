defmodule EducateYour.Segment do
  defstruct(
    video_id: nil,
    title: nil,
    recording_url: nil,
    thumbnail_url: nil,
    starts_at: nil,
    ends_at: nil,
    tags: nil
  )

  def is_tagged?(segment) do
    length(segment.tags) > 0
  end

  def matches_all_tags?(segment, expected_tags) do
    Enum.all?(expected_tags, fn(expected_tag) ->
      Enum.any?(segment.tags, fn(actual_tag) ->
        actual_tag.context == expected_tag.context &&
        actual_tag.text == expected_tag.text
      end)
    end)
  end

  # Input: a list of segments, some of which may be adjacent
  def merge_adjacent(segments) do
    if index_a = find_adjacent_pair(segments) do
      index_b = index_a + 1
      a = Enum.at(segments, index_a)
      b = Enum.at(segments, index_b)
      segments
        |> List.replace_at(index_a, Map.put(a, :ends_at, b.ends_at))
        |> List.delete_at(index_b)
        |> merge_adjacent
    else
      segments
    end
  end

  # Returns the index of the FORMER segment in the pair that should be merged.
  def find_adjacent_pair(segments) do
    # TODO: The delete_at(-1) seems unnecessarily unperformant.
    # There's got to be a more elegant way to do this.
    list_a = segments |> List.delete_at(-1)
    list_b = segments |> List.delete_at(0)
    [list_a, list_b]
      |> List.zip
      |> Enum.find_index(fn({segment_a, segment_b}) ->
        segment_a.video_id == segment_b.video_id &&
        segment_a.ends_at == segment_b.starts_at
      end)
  end

  def debug_list(segments) do
    Enum.map(segments, fn(s) -> debug(s) end)
  end

  def debug(s) do
    tag_texts = s.tags
      |> Enum.map(fn(t) -> "#{t.context}:#{t.text}" end)
      |> Enum.join(", ")
    IO.puts "Video ##{s.video_id} (#{s.starts_at}-#{s.ends_at}) [#{tag_texts}]"
  end
end
