defmodule RTLWeb.Explore.ClipController do
  use RTLWeb, :controller
  alias RTL.Videos

  plug :load_project

  def index(conn, _params) do
    render(conn, "index.html", tag_options: tag_options())
  end

  # Receives an ajax request for video clips given a specific filter
  # Returns a JSON list of video segments for this search
  def playlist(conn, params) do
    render(conn, "playlist.json", tags: tags_from_params(params))
  end

  ##
  # Helpers
  #

  defp tag_options do
    Videos.all_tags_with_counts()
    |> Enum.map(& %{label: "#{&1.name} (#{&1.count})", value: &1.name})
  end

  # TODO: Anytime tags are encoded in urls, we should use id, not name.
  defp tags_from_params(params) do
    (params["tags"] || "")
    |> String.split(",")
    |> Enum.reject(& H.is_blank?(&1))
    |> Enum.map(& %{name: &1})
  end
end
