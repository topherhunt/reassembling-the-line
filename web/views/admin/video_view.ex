defmodule EducateYour.Admin.VideoView do
  use EducateYour.Web, :view

  def tag_list(video) do
    video.coding.tags
      |> Enum.map(fn(tag) -> tag.text end)
      |> Enum.join(", ")
  end
end
