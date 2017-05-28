defmodule Zb.InterviewTest do
  use Zb.ModelCase, async: true

  test "validations" do
    interview = build_with_assocs(:interview)
    assert_validates_presence interview, :admin_changeset, :user_id
    assert_validates_presence interview, :admin_changeset, :question_id
  end

  test "Interviewee validations" do
    # raise "TODO"
  end
end
