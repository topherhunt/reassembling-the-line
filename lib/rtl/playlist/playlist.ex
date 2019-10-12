# Logic for searching for video clips matching a filter
defmodule RTL.Playlist do
  alias RTL.Playlist.Segment
  alias RTL.Videos

  # Outputs a list of matching Segment structs (ie. video clips)
  def build_playlist(project, tags) do
    tags |> Enum.each(& RTL.Helpers.assert_keys(&1, allowed: [:name]))

    Videos.list_videos(project: project, coded: true, having_tags: tags, preload: :tags)
    |> Enum.map(&convert_video_record_to_map(&1))
    |> Enum.flat_map(&split_video_into_segments(&1))
    |> Enum.filter(&Segment.is_tagged?(&1))
    |> Enum.filter(&Segment.matches_all_tags?(&1, tags))
    |> Segment.merge_adjacent()
    |> Enum.shuffle()
  end

  defp convert_video_record_to_map(video) do
    title =
      video.title ||
      (if video.permission_show_name, do: video.speaker_name) ||
      "Anonymous"

    %{
      video_id: video.id,
      title: title,
      recording_url: Videos.video_recording_url(video),
      thumbnail_url: Videos.video_thumbnail_url(video),
      tags: convert_tags_to_maps(video.coding.taggings)
    }
  end

  # Input: a list of Tagging records with associated Tags
  # Output: a list of maps, each summarizing that tag
  # Note that starts_at and ends_at are left in numeric form.
  defp convert_tags_to_maps(taggings) do
    Enum.map(taggings, fn tagging ->
      %{
        name: tagging.tag.name,
        starts_at: tagging.starts_at,
        ends_at: tagging.ends_at
      }
    end)
  end

  # Input: a single Video map
  # Output: a list of Segment structs
  # Note that:
  # - Some tags don't have a start & end time
  # - Any segments with no tags are discarded
  defp split_video_into_segments(video) do
    video.tags
    |> identify_breakpoints
    |> create_empty_segments
    |> populate_segments(video)
  end

  # Input: a list of tags, each in format %{starts_at:, ends_at:}
  # Output: a list of breakpoints, each an integer of seconds
  defp identify_breakpoints(tags) do
    tags
    |> Enum.flat_map(fn tag -> [tag.starts_at || 0, tag.ends_at || 9999] end)
    |> Enum.sort()
    |> Enum.uniq()
  end

  # Input: a list of breakpoints, each an integer of seconds
  # Output: a list of partially-populated Segments
  defp create_empty_segments(breakpoints) do
    start_times = breakpoints |> List.delete_at(-1)
    end_times = breakpoints |> List.delete_at(0)

    [start_times, end_times]
    |> List.zip()
    |> Enum.map(fn {starts_at, ends_at} ->
      %Segment{
        starts_at: starts_at,
        ends_at: ends_at
      }
    end)
  end

  # Returns the list of Segments, but with video & tag data filled in for each
  defp populate_segments(segments, video) do
    Enum.map(segments, fn segment ->
      segment = populate_segment(segment, video)
      Map.put(segment, :segment_id, Segment.hash(segment))
    end)
  end

  defp populate_segment(segment, video) do
    video_data = Map.take(video, [:video_id, :title, :recording_url, :thumbnail_url])

    segment
    |> Map.merge(video_data)
    |> Map.put(:tags, get_segment_tags_list(segment, video.tags))
  end

  defp get_segment_tags_list(segment, tags) do
    tags
    |> Enum.filter(fn tag -> tag_overlaps_with_segment?(tag, segment) end)
    |> Enum.map(fn tag -> Map.drop(tag, [:starts_at, :ends_at]) end)
  end

  defp tag_overlaps_with_segment?(tag, segment) do
    tag_starts_at = tag.starts_at || 0
    tag_ends_at = tag.ends_at || 9999
    tag_starts_at < segment.ends_at && tag_ends_at > segment.starts_at
  end
end
