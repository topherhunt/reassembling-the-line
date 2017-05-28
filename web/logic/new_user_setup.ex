defmodule Zb.NewUserSetup do
  import Ecto
  import Ecto.Query

  alias Zb.{Repo, User, Question}

  def ensure_all_faculy_have_all_interviews do
    User
      |> where([u], u.type == "faculty")
      |> Repo.all
      |> Repo.preload(:interviews)
      |> Enum.each(fn(user) ->
        ensure_user_has_all_interviews(user)
      end)
  end

  def ensure_user_has_all_interviews(user) do
    all_questions() |> Enum.each(fn(q) ->
      if Enum.any?(user.interviews, fn(i) -> i.question_id == q.id end) do
        # This question already has an interview. No action needed.
      else
        IO.puts "Creating interview for user #{user.id} & question #{q.position}."
        user
          |> build_assoc(:interviews, question_id: q.id)
          |> Repo.insert!
      end
    end)
  end

  def all_questions do
    Question |> order_by([q], asc: q.position) |> Repo.all
  end
end
