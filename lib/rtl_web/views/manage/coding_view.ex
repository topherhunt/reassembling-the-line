defmodule RTLWeb.Manage.CodingView do
  use RTLWeb, :view
  alias RTL.Videos

  def all_tags_json(tags), do: tags |> Enum.map(& &1.text) |> Jason.encode!()

  def present_tags_json(tags), do: Jason.encode!(tags)

  def create_or_update_path(conn, video, changeset) do
    project = conn.assigns.project
    # TODO: I think get_field is the cleaner way to do this
    coding_id = changeset.data.id

    if coding_id do
      Routes.manage_video_coding_path(conn, :update, project, video, coding_id)
    else
      Routes.manage_video_coding_path(conn, :create, project, video)
    end
  end
end
