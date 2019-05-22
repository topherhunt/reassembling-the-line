defmodule RTLWeb.Manage.VideoView do
  use RTLWeb, :view

  def tag_list(video) do
    video.coding.tags
    |> Enum.map(fn tag -> tag.text end)
    |> Enum.uniq()
    |> Enum.sort()
  end
end
