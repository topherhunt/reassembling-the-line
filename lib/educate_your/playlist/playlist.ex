# Logic for searching for video clips matching a filter
defmodule EducateYour.Playlist do
  alias EducateYour.Playlist.Segment
  alias EducateYour.Videos

  # INPUT is a list of filter tags in the format %{text:}
  # Outputs a list of matching Segment structs, with adjacent segments merged
  def build_playlist(tags) do
    # TODO: Assert tags is a well-formed list
    Videos.videos_tagged_with(tags)
      |> Enum.map(fn(v) -> convert_video_record_to_map(v) end)
      |> Enum.flat_map(fn(v) -> split_video_into_segments(v) end)
      |> Enum.filter(fn(s) -> Segment.is_tagged?(s) end)
      |> Enum.filter(fn(s) -> Segment.matches_all_tags?(s, tags) end)
      |> Segment.merge_adjacent
      |> Enum.shuffle
  end

  defp convert_video_record_to_map(video) do
    %{
      video_id: video.id,
      title: video.title,
      recording_url: Videos.recording_url(video),
      thumbnail_url: Videos.thumbnail_url(video),
      tags: convert_tags_to_maps(video.coding.taggings)
    }
  end

  # Input: a list of Tagging records with associated Tags
  # Output: a list of maps, each summarizing that tag
  # Note that starts_at and ends_at are left in numeric form.
  defp convert_tags_to_maps(taggings) do
    Enum.map(taggings, fn(tagging)->
      %{
        text: tagging.tag.text,
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
      |> Enum.flat_map(fn(tag) -> [tag.starts_at || 0, tag.ends_at || 9999] end)
      |> Enum.sort
      |> Enum.uniq
  end

  # Input: a list of breakpoints, each an integer of seconds
  # Output: a list of partially-populated Segments
  defp create_empty_segments(breakpoints) do
    start_times = breakpoints |> List.delete_at(-1)
    end_times   = breakpoints |> List.delete_at(0)
    [start_times, end_times]
      |> List.zip
      |> Enum.map(fn({starts_at, ends_at}) ->
        %Segment{
          starts_at: starts_at,
          ends_at: ends_at
        }
      end)
  end

  # Returns the list of Segments, but with video & tag data filled in for each
  defp populate_segments(segments, video) do
    video_data = Map.take(video, [:video_id, :title, :recording_url, :thumbnail_url])
    Enum.map(segments, fn(segment) ->
      segment = segment
        |> Map.merge(video_data)
        |> Map.put(:tags, get_segment_tags_list(segment, video.tags))
      Map.put(segment, :segment_id, Segment.hash(segment))
    end)
  end

  defp get_segment_tags_list(segment, tags) do
    tags
      |> Enum.filter(fn(tag) ->
        (tag.starts_at || 0) < segment.ends_at &&
        (tag.ends_at || 9999) > segment.starts_at
      end)
      |> Enum.map(fn(tag) -> Map.drop(tag, [:starts_at, :ends_at]) end)
  end
end
