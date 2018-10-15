defmodule EducateYourWeb.ExploreView do
  use EducateYourWeb, :view

  def render("playlist.json", %{tags: tags}) do
    %{playlist: EducateYour.Playlist.build_playlist(tags)}
  end
end
