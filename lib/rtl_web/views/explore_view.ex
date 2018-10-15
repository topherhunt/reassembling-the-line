defmodule RTLWeb.ExploreView do
  use RTLWeb, :view

  def render("playlist.json", %{tags: tags}) do
    %{playlist: RTL.Playlist.build_playlist(tags)}
  end
end
