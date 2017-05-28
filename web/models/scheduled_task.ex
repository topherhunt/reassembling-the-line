# Each specific task we want users to do.
# TODO: I made some bad decisions when structuring this. Ideally:
# - Add a new field `interview_id` which points to my interview record.
#   This also means we change `command` to `type` ("interview" or "vote").
# - Add boolean `complete` which is set to true when I submit the relevant
#   interview, or submit enough votes to meet my quota.
# Benefits of this:
# - The complex logic around TaskComputer and ScheduledTaskRunner become simpler
#   and more transparent
# - It becomes easier to set up data state in tests. Currently it's very intricate.
# - In case statements for "next available task" etc., I can return just the
#   Task record itself and pattern-match on its `type` field.
defmodule Zb.ScheduledTask do
  use Zb.Web, :model

  schema "scheduled_tasks" do
    belongs_to :user, Zb.User
    field :command, :string # the thing we want to get the user to do
    field :due_on_date, Timex.Ecto.Date # NOTE: 2+ tasks may be due on the same day
    field :notified_at, Timex.Ecto.DateTime # UTC - may be nil - email was sent
    field :skipped_at, Timex.Ecto.DateTime # UTC - may be nil - email was skipped (task was already complete)
    timestamps()
  end

  def changeset(struct, params \\ %{}) do
    struct
      |> cast(params, [:user_id, :command, :due_on_date])
      |> validate_required([:user_id, :command, :due_on_date])
      |> validate_inclusion(:command, ["do_interview:1", "do_interview:2", "do_interview:3", "meet_voting_quota"])
      |> assoc_constraint(:user)
  end

  # Queries

  def due_now(query) do
    query |> where([t], t.due_on_date <= ^Timex.today)
  end

  def not_yet_due(query) do
    query |> where([t], t.due_on_date > ^Timex.today)
  end

  def notification_sent(query) do
    query |> where([t], not is_nil(t.notified_at))
  end

  def notification_skipped(query) do
    query |> where([t], not is_nil(t.skipped_at))
  end

  def not_yet_notified(query) do
    query |> where([t], is_nil(t.notified_at) and is_nil(t.skipped_at))
  end
end
