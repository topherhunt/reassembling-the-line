defmodule RTLWeb.Admin.CodingView do
  use RTLWeb, :view
  alias RTL.Videos

  def all_tags_json(tags), do: tags |> Enum.map(& &1.text) |> Jason.encode!

  def present_tags_json(tags), do: Jason.encode!(tags)

  def create_or_update_path(conn, changeset) do
    if changeset.data.id do
      admin_coding_path(conn, :update, changeset.data.id)
    else
      admin_coding_path(conn, :create)
    end
  end
end
