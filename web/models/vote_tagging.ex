defmodule Zb.VoteTagging do
  use Zb.Web, :model

  schema "vote_taggings" do
    belongs_to :vote, Zb.Vote # indexed
    belongs_to :tag, Zb.Tag # indexed
    timestamps()
  end
end
