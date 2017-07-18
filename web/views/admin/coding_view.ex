defmodule EducateYour.Admin.CodingView do
  use EducateYour.Web, :view

  def all_tags_json(tags, context) do
    tags
      |> Enum.filter(fn(tag) -> tag.context == context end)
      |> Enum.map(fn(tag) -> tag.text end)
      |> Poison.encode!()
  end

  def present_tags_json(tags, context) do
    tags
      |> Enum.filter(fn(tag) -> tag[:context] == context end)
      |> Poison.encode!()
  end

  def create_or_update_path(conn, changeset) do
    if changeset.data.id do
      admin_coding_path(conn, :update, changeset.data.id)
    else
      admin_coding_path(conn, :create)
    end
  end
end
