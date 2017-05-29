defmodule EducateYour.Factory do
  use ExMachina.Ecto, repo: EducateYour.Repo

  alias EducateYour.{User, Video, Coding, Tagging, Tag}

  # Returns an unpersisted struct with all foreign key _id fields populated.
  # Useful when testing validations: we need a valid, unpersisted struct that
  # contains all the fields accepted by the changeset.
  def build_with_assocs(factory, opts \\ %{}) do
    build(factory, params_with_assocs(factory, opts))
  end

  def user_factory do
    hex = random_hex()
    %User{
      full_name: "User #{hex}",
      email: "user_#{hex}@example.com",
      uuid: random_hex() <> random_hex()
    }
  end

  def video_factory do
    hex = random_hex()
    %Video{
      title: "Video #{hex}",
      recording_url: "http://www.example.com/videos/#{hex}"
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
      video: build(:video),
      coding: build(:coding),
      tag: build(:tag)
    }
  end

  def tag_factory do
    %Tag{
      context: Enum.random(Tag.valid_contexts),
      text: "tag_#{random_hex()}"
    }
  end

  # Helpers

  defp random_hex do
    :crypto.strong_rand_bytes(4) |> Base.encode16
  end
end
