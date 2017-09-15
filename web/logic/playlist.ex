# Logic for searching for video clips matching a filter
defmodule EducateYour.Playlist do
  import Ecto.Query
  alias EducateYour.{H, Repo, Video, Segment}

  # INPUT is a list of filter tags in the format %{text:}
  # Outputs a list of matching Segment structs, with adjacent segments merged
  def search(tags) do
    load_matching_videos(tags)
      |> Enum.map(fn(v) -> convert_video_record_to_map(v) end)
      |> Enum.flat_map(fn(v) -> split_video_into_segments(v) end)
      |> Enum.filter(fn(s) -> Segment.is_tagged?(s) end)
      |> Enum.filter(fn(s) -> Segment.matches_all_tags?(s, tags) end)
      |> Segment.merge_adjacent
      # |> H.tap("Merged segments:", &Segment.debug_list/1)
      |> Enum.shuffle
  end

  def load_matching_videos(tags) do
    Video
      |> join(:left, [v], c in assoc(v, :coding))
      |> exclude_videos_with_no_tags
      |> filter_query_by_tags(tags)
      |> preload(coding: [taggings: :tag])
      |> Repo.all
  end

  def exclude_videos_with_no_tags(query) do
    query |> where([v, c],
      fragment("EXISTS (SELECT * FROM taggings WHERE coding_id = ?)", c.id))
  end

  def filter_query_by_tags(query, tags) do
    Enum.reduce(tags, query, fn(tag, query) ->
      query |> where([v, c], fragment("
        EXISTS (
          SELECT * FROM taggings ti
          LEFT JOIN tags t ON ti.tag_id = t.id
          WHERE ti.coding_id = ? AND t.text = ?
        )",
        c.id, ^tag[:text]))
    end)
  end

  def convert_video_record_to_map(video) do
    %{
      video_id: video.id,
      title: video.title,
      recording_url: Video.recording_url(video),
      thumbnail_url: Video.thumbnail_url(video),
      tags: convert_tags_to_maps(video.coding.taggings)
    }
  end

  # Input: a list of Tagging records with associated Tags
  # Output: a list of maps, each summarizing that tag
  # Note that starts_at and ends_at are left in numeric form.
  def convert_tags_to_maps(taggings) do
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
  def split_video_into_segments(video) do
    video.tags
      |> identify_breakpoints
      |> create_empty_segments
      |> populate_segments(video)
  end

  # Input: a list of tags, each in format %{starts_at:, ends_at:}
  # Output: a list of breakpoints, each an integer of seconds
  def identify_breakpoints(tags) do
    tags
      |> Enum.flat_map(fn(tag) -> [tag.starts_at || 0, tag.ends_at || 9999] end)
      |> Enum.sort
      |> Enum.uniq
  end

  # Input: a list of breakpoints, each an integer of seconds
  # Output: a list of partially-populated Segments
  def create_empty_segments(breakpoints) do
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
  def populate_segments(segments, video) do
    video_data = Map.take(video, [:video_id, :title, :recording_url, :thumbnail_url])
    Enum.map(segments, fn(segment) ->
      segment = segment
        |> Map.merge(video_data)
        |> Map.put(:tags, get_segment_tags_list(segment, video.tags))
      Map.put(segment, :segment_id, Segment.hash(segment))
    end)
  end

  def get_segment_tags_list(segment, tags) do
    tags
      |> Enum.filter(fn(tag) ->
        (tag.starts_at || 0) < segment.ends_at &&
        (tag.ends_at || 9999) > segment.starts_at
      end)
      |> Enum.map(fn(tag) -> Map.drop(tag, [:starts_at, :ends_at]) end)
  end
end
