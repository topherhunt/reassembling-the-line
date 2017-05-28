defmodule Zb.VoteController do
  use Zb.Web, :controller
  alias Zb.Interview
  alias Zb.Vote
  alias Zb.Tag

  plug :require_user
  plug :scrub_params, "vote" when action in [:create]

  def select_random(conn, _) do
    if interview = random_votable_interview(conn) do
      redirect conn, to: interview_vote_path(conn, :new, interview.id)
    else
      # There's no interviews left to vote on.
      redirect conn, to: vote_path(conn, :done)
    end
  end

  def new(conn, %{"interview_id" => interview_id}) do
    interview = Repo.get!(Interview, interview_id) |> Repo.preload(:question)
    changeset = conn.assigns.current_user
      |> build_assoc(:votes)
      |> Vote.voter_changeset()
    render conn, "new.html", interview: interview, changeset: changeset, recommended_tags: recommended_tags()
  end

  def create(conn, %{"interview_id" => interview_id, "vote" => vote_params}) do
    interview = Repo.get!(Interview, interview_id) |> Repo.preload(:question)
    changeset = conn.assigns.current_user
      |> build_assoc(:votes, interview_id: interview.id)
      |> Vote.voter_changeset(vote_params)
    case Repo.insert(changeset) do
      {:ok, vote} ->
        create_tag_associations(vote, vote_params["tag_list"])
        conn
          |> put_flash(:info, "Thanks! Your ratings have been saved.")
          |> redirect(to: vote_path(conn, :select_random))
      {:error, changeset} ->
        render conn, "new.html", interview: interview, changeset: changeset, recommended_tags: recommended_tags()
    end
  end

  def done(conn, _) do
    render conn, "done.html"
  end

  # === Helpers ===

  defp random_votable_interview(conn) do
    user = conn.assigns.current_user
    Interview
      |> Interview.completed
      |> Interview.not_by(user)
      |> Interview.not_voted_on_by(user)
      |> Interview.eligible_for_voting
      |> order_by(fragment("RANDOM()"))
      |> Repo.first
  end

  defp recommended_tags do
    Tag
      |> where([t], t.recommended == true)
      |> order_by([t], asc: t.text)
      |> Repo.all
  end

  defp create_tag_associations(vote, tag_list) do
    tag_list
      |> String.split(",")
      |> Enum.each(fn(tag_text) ->
        changeset = Tag.voter_changeset(%Tag{}, %{text: tag_text})
        cleaned_text = Ecto.Changeset.get_change(changeset, :text)
        tag = Repo.get_by(Tag, text: cleaned_text) || Repo.insert!(changeset)
        Repo.insert!(%Zb.VoteTagging{vote: vote, tag: tag})
      end)
  end
end
