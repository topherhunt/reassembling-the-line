defmodule RTLWeb.Explore.VideoView do
  use RTLWeb, :view
  alias RTL.Videos

  def title_for_video(video) do
    cond do
      video.title != nil -> video.title
      video.permission_show_name -> video.speaker_name
      true -> "Anonymous video"
    end
  end
end
