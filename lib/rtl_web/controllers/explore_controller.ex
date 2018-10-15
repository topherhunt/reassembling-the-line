defmodule RTLWeb.ExploreController do
  use RTLWeb, :controller
  alias RTL.Videos

  def index(conn, _params) do
    render conn, "index.html", tag_options: tag_options()
  end

  # Receives an ajax request for video clips given a specific filter
  # Returns a JSON list of video segments for this search
  def playlist(conn, params) do
    render conn, "playlist.json", tags: tags_from_params(params)
  end

  ##
  # Helpers
  #

  defp tag_options do
    Videos.all_tags_with_counts
    |> Enum.map(& %{label: "#{&1.text} (#{&1.count})", value: &1.text})
  end

  defp tags_from_params(params) do
    (params["tags"] || "")
      |> String.split(",")
      |> Enum.reject(& Helpers.is_blank?(&1))
      |> Enum.map(& %{text: &1})
  end
end
