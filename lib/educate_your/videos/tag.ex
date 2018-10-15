defmodule EducateYour.Videos.Tag do
  use Ecto.Schema
  import Ecto.Changeset

  schema "tags" do
    field :text, :string
    timestamps()

    has_many :taggings, EducateYour.Videos.Tagging
  end

  ##
  # Changesets
  #

  def changeset(struct, params \\ %{}) do
    struct
      |> cast(params, [:text])
      |> validate_required([:text])
      |> validate_tag_has_no_special_chars
  end

  def validate_tag_has_no_special_chars(changeset) do
    text = get_field(changeset, :text)
    if String.match?((text || ""), ~r/\A[\w\d \-\_]+\z/) do
      changeset
    else
      add_error(changeset, :text, "Must only contain letters, numbers, and spaces.")
    end
  end
end
