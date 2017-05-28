defmodule Zb.VoteTest do
  use Zb.ModelCase, async: true
  alias Zb.Vote

  test "validations" do
    vote = build_with_assocs(:vote, tag_list: "apple,bear")
    assert_validates_presence(vote, :voter_changeset, :vote_agreement)
    assert_validates_presence(vote, :voter_changeset, :vote_influenced)
    assert_validates_inclusion(vote, :voter_changeset, :vote_agreement, %{valids: [1, 2, 3, 4], invalids: [0, 5]})
    assert_validates_inclusion(vote, :voter_changeset, :vote_influenced, %{valids: [1, 2, 3, 4], invalids: [0, 5]})
  end

  test "validates that user_id is present" do
    user = insert :user
    interview = insert :interview
    vote = build :vote, interview_id: interview.id, tag_list: "apple,bear" # no user_id
    refute Vote.voter_changeset(vote, %{}).valid?
    assert Vote.voter_changeset(%{vote | user_id: user.id}, %{}).valid?
  end

  test "validates that interview_id is present" do
    user = insert :user
    interview = insert :interview
    vote = build :vote, user_id: user.id, tag_list: "apple,bear" # no interview_id
    refute Vote.voter_changeset(vote, %{}).valid?
    assert Vote.voter_changeset(%{vote | interview_id: interview.id}, %{}).valid?
  end

  test "validates presence of user_id in the struct" do
    user = insert :user
    interview = insert :interview
    vote = build :vote, interview_id: interview.id, tag_list: "apple,bear" # no user_id
    refute Vote.voter_changeset(vote, %{}).valid?
    assert Vote.voter_changeset(%{vote | user_id: user.id}, %{}).valid?
  end

  test "validates that it has 1-2 existing, non-blank tags" do
    insert :tag, text: "apple"
    insert :tag, text: "bear"
    insert :tag, text: "cat"
    vote = build_with_assocs(:vote)

    assert Zb.Vote.voter_changeset(vote, %{tag_list: "apple"}).valid?
    assert Zb.Vote.voter_changeset(vote, %{tag_list: "apple,bear"}).valid?
    refute Zb.Vote.voter_changeset(vote, %{tag_list: "apple,bear,cat"}).valid? # too many
    refute Zb.Vote.voter_changeset(vote, %{tag_list: " , "}).valid? # no non-blank tag
  end
end
