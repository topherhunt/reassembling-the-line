defmodule EducateYour.ExploreView do
  use EducateYour.Web, :view
  alias EducateYour.Playlist

  def render("playlist.json", %{tags: tags}) do
    %{playlist: Playlist.search(tags)}
  end
end
