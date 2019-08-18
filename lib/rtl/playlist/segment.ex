defmodule RTL.Playlist.Segment do
  # all fields are json-serializable
  @derive Jason.Encoder
  defstruct(
    # a hash string unique to this video_id, starts_at, ends_at
    segment_id: nil,
    video_id: nil,
    title: nil,
    recording_url: nil,
    thumbnail_url: nil,
    starts_at: nil,
    ends_at: nil,
    # array of tag maps: %{name:, starts_at:, ends_at:}
    tags: nil
  )

  # A random-looking but fixed alphanumeric ID unique to this video clip
  # We use this as each segment's id so that we can sort them in a fixed order etc.
  def hash(segment) do
    string = "#{segment.video_id}-#{segment.starts_at}-#{segment.ends_at}"
    :crypto.hash(:md5, string) |> Base.encode16()
  end

  def is_tagged?(segment) do
    length(segment.tags) > 0
  end

  def matches_all_tags?(segment, expected_tags) do
    Enum.all?(expected_tags, fn expected_tag ->
      Enum.any?(segment.tags, fn actual_tag ->
        actual_tag.name == expected_tag.name
      end)
    end)
  end

  # Input: a list of segments, some of which may be adjacent
  # Output: The same list, but with adjacent segments merged into 1 segment
  def merge_adjacent(segments) do
    if index_a = find_adjacent_pair(segments) do
      index_b = index_a + 1
      old_a = Enum.at(segments, index_a)
      old_b = Enum.at(segments, index_b)

      new_a =
        old_a
        |> Map.put(:ends_at, old_b.ends_at)
        |> Map.put(:tags, Enum.uniq(old_a.tags ++ old_b.tags))

      segments
      |> List.replace_at(index_a, new_a)
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
    |> List.zip()
    |> Enum.find_index(fn {segment_a, segment_b} ->
      segment_a.video_id == segment_b.video_id &&
        segment_a.ends_at == segment_b.starts_at
    end)
  end

  def debug_list(segments) do
    Enum.map(segments, fn s -> debug(s) end)
  end

  def debug(s) do
    tag_names = s.tags |> Enum.map(& &1.name) |> Enum.join(", ")
    IO.puts("Video ##{s.video_id} (#{s.starts_at}-#{s.ends_at}) [#{tag_names}]")
  end
end
