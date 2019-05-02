defmodule RTLWeb.Manage.VideoView do
  use RTLWeb, :view

  def tag_list(video) do
    video.coding.tags
    |> Enum.map(fn tag -> tag.text end)
    |> Enum.uniq()
    |> Enum.sort()
  end

  def link_to_source(video) do
    if video.source_url do
      link(video.source_name || video.source_url, to: video.source_url)
    else
      video.source_name
    end
  end
end
