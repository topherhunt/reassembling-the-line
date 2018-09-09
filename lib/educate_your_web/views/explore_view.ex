defmodule EducateYourWeb.ExploreView do
  use EducateYourWeb, :view
  alias EducateYour.Logic.Playlist

  def render("playlist.json", %{tags: tags}) do
    %{playlist: Playlist.search(tags)}
  end
end
