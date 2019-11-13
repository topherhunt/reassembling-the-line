defmodule RTLWeb.Manage.VideoView do
  use RTLWeb, :view

  def tag_list(video) do
    video.coding.tags
    |> Enum.map(& &1.name)
    |> Enum.uniq()
    |> Enum.sort()
  end
end
