defmodule RTLWeb.Manage.VideoExportController do
  use RTLWeb, :controller

  plug :load_project
  plug :ensure_can_manage_project

  def new(conn, _params) do
    render conn, "new.html", videos_json: videos_json(conn.assigns.project)
  end

  #
  # Helpers
  #

  defp videos_json(project) do
    RTL.Videos.get_videos(project: project)
    |> Enum.map(& to_map(&1))
    |> Jason.encode!()
  end

  defp to_map(v) do
    %{
      title: v.title,
      speaker_name: v.speaker_name,
      source_url: v.source_url,
      permission: v.permission,
      recording_filename: v.recording_filename,
      thumbnail_filename: v.thumbnail_filename
    }
  end
end
