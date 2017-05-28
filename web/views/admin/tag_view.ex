defmodule Zb.Admin.TagView do
  use Zb.Web, :view

  alias Zb.Repo

  def ct_uses(tag) do
    tag |> Ecto.assoc(:vote_taggings) |> Repo.count
  end
end
