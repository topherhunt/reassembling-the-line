defmodule EducateYour.Factory do
  use ExMachina.Ecto, repo: EducateYour.Repo

  alias EducateYour.{H, User, Video, Coding, Tagging, Tag}

  # Returns an unpersisted struct with all foreign key _id fields populated.
  # Useful when testing validations: we need a valid, unpersisted struct that
  # contains all the fields accepted by the changeset.
  def build_with_assocs(factory, opts \\ %{}) do
    build(factory, params_with_assocs(factory, opts))
  end

  # NOTE: Be careful with `params_with_assocs`. It behaves in counterintuitive
  # ways when you override associations or FK fields. Best practice is to
  # only ever call `params_with_assocs\1` and then Map.merge any FK overrides.

  def user_factory do
    hex = H.random_hex()
    %User{
      full_name: "User #{hex}",
      email: "user_#{hex}@example.com",
      uuid: H.random_hex() <> H.random_hex()
    }
  end

  def video_factory do
    hex = H.random_hex()
    %Video{
      title: "Video #{hex}",
      recording_filename: "#{hex}.webm",
      thumbnail_filename: "#{hex}.jpg"
    }
  end

  def coding_factory do
    %Coding{
      video: build(:video),
      updated_by_user: build(:user)
    }
  end

  def tagging_factory do
    %Tagging{
      coding: build(:coding),
      tag: build(:tag)
    }
  end

  def tag_factory do
    %Tag{
      text: "tag_#{H.random_hex()}"
    }
  end
end
