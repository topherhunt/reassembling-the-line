defmodule EducateYour.ExploreController do
  use EducateYour.Web, :controller
  alias EducateYour.{Tag}

  def index(conn, _params) do
    render conn, "index.html", tags: tags_by_context()
  end

  # Receives an ajax request for video clips given a specific filter
  # Returns a JSON list of video segments for this search
  def playlist(conn, params) do
    render conn, "playlist.json", tags: tags_from_params(params)
  end

  ##
  # Helpers
  #

  defp tags_by_context do
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
      |> order_by([t], t.text)
      |> Repo.all
      |> Enum.map(fn(tag) -> tag.text end)
  end

  defp tags_from_params(params) do
    (params["tags"] || "")
      |> String.split(",")
      |> Enum.map(fn(encoded_tag) ->
        [context, text] = String.split(encoded_tag, ":")
        %{context: context, text: text}
      end)
  end
end
