defmodule RTLWeb.ResultsController do
  use RTLWeb, :controller
  alias RTL.Videos

  plug :load_project

  def index(conn, _params) do
    project = conn.assigns.project
    render(conn, "index.html", tag_options: tag_options(project))
  end

  # Receives an ajax request for video clips given a specific filter
  # Returns a JSON list of video segments for this search
  def playlist(conn, params) do
    project = conn.assigns.project
    tags = tags_from_params(params)
    conn |> json(%{playlist: RTL.Playlist.build_playlist(project, tags)})
  end

  ##
  # Helpers
  #

  defp tag_options(project) do
    Videos.all_tags_with_counts(project)
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
