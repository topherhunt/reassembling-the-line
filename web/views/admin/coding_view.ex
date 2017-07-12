defmodule EducateYour.Admin.CodingView do
  use EducateYour.Web, :view

  def tags_for_context(tags, context) do
    tags
      |> Enum.filter(fn(tag) -> tag.context == context end)
      |> Enum.map(fn(tag) -> tag.name end)
  end
end
