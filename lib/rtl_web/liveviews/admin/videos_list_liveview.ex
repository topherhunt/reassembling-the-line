defmodule RTLWeb.Manage.VideosListLiveview do
  use Phoenix.LiveView
  use Phoenix.HTML
  alias RTL.Videos
  require Logger

  # The session is for data that won't change for the duration of this process,
  # data that "defines" this view. e.g. the id of the video it's rendering for.
  def mount(%{project: project}, socket) do
    if connected?(socket), do: RTL.Videos.subscribe_to(:all)
    socket = assign(socket, :project, project)
    {:ok, fetch_latest_data(socket)}
  end

  def render(assigns) do
    RTLWeb.Manage.VideoView.render("list.html", assigns)
  end

  def handle_event("delete_video" = type, id, socket) do
    log "handle_event called with #{type}, #{id}."
    Videos.get_video!(id) |> Videos.delete_video!()
    {:noreply, socket}
  end

  # Listen for any notifications from the Videos context
  def handle_info({RTL.Videos = source, event_string}, socket) do
    log "handle_info called with #{source}, #{event_string}."
    {:noreply, fetch_latest_data(socket)}
  end

  defp fetch_latest_data(socket) do
    log "fetch_latest_data called."

    assign(socket,
      videos:
        Videos.get_videos(
          project: socket.assigns.project,
          order: :last_coded,
          preload: [coding: [:updated_by_user, :tags]]
        ),
      next_uncoded_video: Videos.get_video_by(coded: false, order: :oldest)
    )
  end

  defp log(message), do: Logger.info("#{__MODULE__}: #{message}")
end
