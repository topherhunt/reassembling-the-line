defmodule RTLWeb.Admin.VideosListLiveview do
  use Phoenix.LiveView
  use Phoenix.HTML
  alias RTL.Videos
  require Logger

  def mount(%{current_user: current_user, project: project}, socket) do
    if connected?(socket), do: RTL.Videos.subscribe_to(:all)
    socket = assign(socket, %{current_user: current_user, project: project})
    {:ok, fetch_latest_data(socket)}
  end

  def render(assigns) do
    RTLWeb.Admin.VideoView.render("list.html", assigns)
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
    project = socket.assigns.project

    assign(socket,
      videos:
        Videos.list_videos(
          project: project,
          order: :last_coded,
          preload: [coding: [:coder, :tags]]
        ),
      next_uncoded_video: Videos.get_video_by(
        project: project,
        coded: false,
        order: :last_coded
      )
    )
  end

  defp log(message), do: Logger.info("#{__MODULE__}: #{message}")
end
