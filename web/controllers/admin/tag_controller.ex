defmodule Zb.Admin.TagController do
  use Zb.Web, :controller

  alias Zb.Tag

  def index(conn, _params) do
    render conn, "index.html", tags: all_tags()
  end

  # Helpers

  defp all_tags do
    Tag
      |> order_by([t], asc: t.text)
      |> Repo.all
    # TODO: The ordering by count doesn't appear to work. Why?
      # |> join(:inner, [t], vt in VoteTagging, t.id == vt.id)
      # |> group_by([t, vt], [t.id])
      # |> order_by([t, vt], desc: count(vt.id))
  end
end
