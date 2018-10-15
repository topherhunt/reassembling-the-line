defmodule EducateYourWeb.Admin.CodingView do
  use EducateYourWeb, :view
  alias EducateYour.Videos

  def all_tags_json(tags), do: tags |> Enum.map(& &1.text) |> Poison.encode!

  def present_tags_json(tags), do: Poison.encode!(tags)

  def create_or_update_path(conn, changeset) do
    if changeset.data.id do
      admin_coding_path(conn, :update, changeset.data.id)
    else
      admin_coding_path(conn, :create)
    end
  end
end
