defmodule EducateYourWeb.Admin.CodingView do
  use EducateYourWeb, :view
  alias EducateYour.Schemas.Video

  def all_tags_json(tags) do
    tags
      |> Enum.map(fn(tag) -> tag.text end)
      |> Poison.encode!()
  end

  def present_tags_json(tags) do
    tags
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
