defmodule Zb.Admin.InterviewView do
  use Zb.Web, :view
  alias Zb.{Repo, VoteTagging, Tag}
  require Ecto.Query

  def describe_status(interview) do
    if interview.completed_at do
      "<span class='text-success'>complete</span>"
    else
      "<span class='text-warning'>pending</span>"
    end |> raw
  end

  def describe_vote_value(value) do
    case value do
      1 -> "1 (Strongly disagree)"
      2 -> "2 (Disagree)"
      3 -> "3 (Agree)"
      4 -> "4 (Strongly agree)"
    end
  end

  def describe_vote_tags(vote) do
    vote.tags |> Enum.map(& &1.text) |> Enum.sort |> Enum.join(", ")
  end

  # Queries
  # These are all very unperformant and N+1-ish.

  def avg_vote_agreement(interview) do
    value = interview
      |> Ecto.assoc(:votes)
      |> Ecto.Query.select([v], avg(v.vote_agreement))
      |> Repo.one
    if value, do: Decimal.round(value, 2)
  end

  def avg_vote_influenced(interview) do
    value = interview
      |> Ecto.assoc(:votes)
      |> Ecto.Query.select([v], avg(v.vote_influenced))
      |> Repo.one
    if value, do: Decimal.round(value, 2)
  end

  def ct_votes(interview) do
    interview |> Ecto.assoc(:votes) |> Repo.count
  end

  def top_tags(interview) do
    # TODO: Try this as a keyword-syntax query and see if it looks less scary
    interview
      |> Ecto.assoc(:votes)
      |> Ecto.Query.join(:inner, [v], vt in VoteTagging, v.id == vt.vote_id)
      |> Ecto.Query.join(:inner, [v, vt], t in Tag, vt.tag_id == t.id)
      |> Ecto.Query.select([v, vt, t], {t.text, count(vt.id)})
      |> Ecto.Query.group_by([v, vt, t], [t.id, t.text])
      |> Ecto.Query.order_by([v, vt, t], desc: count(vt.id))
      |> Ecto.Query.limit(2)
      |> Repo.all # output looks like [{"spiritual", 5}, {"physical", 2}]
      |> Enum.map(fn({label, count}) -> "#{label} (#{count})" end)
      |> Enum.join(", ")
    # Result: eg. "spiritual (5), physical (2)"
  end
end
