defmodule Zb.Factory do
  use ExMachina.Ecto, repo: Zb.Repo

  # Returns an unpersisted struct with all foreign key _id fields populated.
  # Useful when testing validations: we need a valid, unpersisted struct that
  # contains all the fields accepted by the changeset.
  def build_with_assocs(factory, opts \\ %{}) do
    build(factory, params_with_assocs(factory, opts))
  end

  def user_factory do
    hex = random_hex()
    %Zb.User{
      type: "faculty",
      email: "person_#{hex}@example.com",
      full_name: "Person #{hex}",
      password: "password",
      password_hash: Comeonin.Bcrypt.hashpwsalt("password"), # lazy attrs not yet supported
      uuid: random_hex() <> random_hex(),
      min_votes_needed: 0 # tests are less brittle when this defaults to 0
    }
  end

  def question_factory do
    %Zb.Question{
      position: 1,
      text: "Question #{random_hex()}",
      eligible_for_voting: false
    }
  end

  def interview_factory do
    %Zb.Interview{
      user: build(:user),
      question: build(:question)
    }
  end

  def vote_factory do
    %Zb.Vote{
      user: build(:user),
      interview: build(:interview),
      vote_agreement: :rand.uniform(4),
      vote_influenced: :rand.uniform(4)
    }
  end

  def tag_factory do
    %Zb.Tag{
      text: "Tag #{random_hex()}"
    }
  end

  def vote_tagging_factory do
    %Zb.VoteTagging{
      vote: build(:vote),
      tag: build(:tag)
    }
  end

  def scheduled_task_factory do
    %Zb.ScheduledTask{
      user: build(:user),
      command: "do_interview:1",
      due_on_date: Timex.today
    }
  end

  def contact_request_factory do
    %Zb.ContactRequest{
      user: build(:user),
      email: "person_#{random_hex()}@example.com",
      subject: "Some subject",
      body: "Some body"
    }
  end

  # Helpers

  defp random_hex do
    :crypto.strong_rand_bytes(4) |> Base.encode16
  end
end
