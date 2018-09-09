defmodule EducateYourWeb.ExploreController do
  use EducateYourWeb, :controller
  import Ecto.Query
  alias EducateYour.Repo
  alias EducateYour.Schemas.{Tag, Tagging}
  alias EducateYour.Helpers

  def index(conn, _params) do
    render conn, "index.html", all_tags: all_tags()
  end

  # Receives an ajax request for video clips given a specific filter
  # Returns a JSON list of video segments for this search
  def playlist(conn, params) do
    render conn, "playlist.json", tags: tags_from_params(params)
  end

  ##
  # Helpers
  #

  defp all_tags do
    Tag
      |> join(:inner, [t], ti in Tagging, t.id == ti.tag_id)
      |> group_by([t, ti], [t.text])
      |> select([t, ti], {t.text, count(ti.id)})
      |> order_by([t, ti], [desc: count(ti.id), asc: t.text])
      |> Repo.all
      |> Enum.map(fn({text, ct}) -> %{value: text, label: "#{text} (#{ct})"} end)
  end

  defp tags_from_params(params) do
    (params["tags"] || "")
      |> String.split(",")
      |> Enum.reject(&Helpers.is_blank?/1)
      |> Enum.map(fn(text) -> %{text: text} end)
  end
end
