defmodule RTLWeb.Live.Admin.VideosList do
  use Phoenix.LiveView
  use Phoenix.HTML
  alias RTL.Videos
  require Logger

  # The session is for data that won't change for the duration of this process,
  # data that "defines" this view. e.g. the id of the video it's rendering for.
  def mount(_session, socket) do
    if connected?(socket), do: RTL.Videos.subscribe_to(:all)
    {:ok, fetch_latest_data(socket)}
  end

  def render(assigns) do
    RTLWeb.Admin.VideoView.render("index.html", assigns)
  end

  def handle_event("delete_video" = type, id, socket) do
    log "handle_event called with #{type}, #{id}."
    Videos.get_video!(id) |> Videos.delete_video!()
    {:noreply, socket}
  end

  # Listen for any notifications from the Videos context
  def handle_info({RTL.Videos = source, event_string}, socket) do
    log "handle_info called with #{source}, #{event_string}."
    # TODO: What happens if we return an invalid option like :ok?
    {:noreply, fetch_latest_data(socket)}
  end

  defp fetch_latest_data(socket) do
    log "fetch_latest_data called."
    assign(socket,
      videos: Videos.all_videos_with_preloads(),
      # next_uncoded_video is unnecessary. We could just have the button there
      # and when you click it, it looks up the next video to code, if any.
      next_uncoded_video: Videos.next_video_to_code()
    )
  end

  defp log(message), do: Logger.info("#{__MODULE__}: #{message}")
end
