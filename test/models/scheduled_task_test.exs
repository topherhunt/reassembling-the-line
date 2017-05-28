defmodule Zb.ScheduledTaskTest do
  use Zb.ModelCase, async: true

  test "validations" do
    task = build_with_assocs(:scheduled_task)
    assert_validates_presence task, :changeset, :user_id
    assert_validates_presence task, :changeset, :command
    assert_validates_presence task, :changeset, :due_on_date
    assert_validates_inclusion task, :changeset, :command, %{valids: ["do_interview:1", "do_interview:2", "do_interview:3", "meet_voting_quota"], invalids: ["do_nothing"]}
  end
end
