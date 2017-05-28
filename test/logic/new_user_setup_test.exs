defmodule Zb.NewUserSetupTest do
  use Zb.ModelCase, async: true

  test "#ensure_all_faculy_have_all_interviews idempotently populates missing interviews" do
    raise "TODO"
  end

  test "#ensure_scheduled_task_for_all_faculty idempotently schedules a single task for all faculty members" do
    raise "TODO"
    # e.g. NewUserSetup.ensure_scheduled_task_for_all_faculty(command: "blah", due_on_date: Timex.today)
  end
end
