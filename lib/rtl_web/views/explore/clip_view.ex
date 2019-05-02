defmodule RTLWeb.Explore.ClipView do
  use RTLWeb, :view

  def render("playlist.json", %{project: project, tags: tags}) do
    %{playlist: RTL.Playlist.build_playlist(project, tags)}
  end
end
