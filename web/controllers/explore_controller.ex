defmodule EducateYour.ExploreController do
  use EducateYour.Web, :controller
  alias EducateYour.{H, Tag, Tagging}

  def index(conn, _params) do
    render conn, "index.html", all_tags: all_tags_by_context()
  end

  # Receives an ajax request for video clips given a specific filter
  # Returns a JSON list of video segments for this search
  def playlist(conn, params) do
    render conn, "playlist.json", tags: tags_from_params(params)
  end

  ##
  # Helpers
  #

  defp all_tags_by_context do
    %{
      location: load_tags("location"),
      demographic: load_tags("demographic"),
      sentiment: load_tags("sentiment"),
      topic: load_tags("topic")
    }
  end

  defp load_tags(context) do
    Tag
      |> where([t], t.context == ^context)
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
      |> Enum.reject(&H.is_blank?/1)
      |> Enum.map(fn(encoded_tag) ->
        [context, text] = String.split(encoded_tag, ":")
        %{context: context, text: text}
      end)
  end
end
