defmodule EducateYour.Tag do
  use EducateYour.Web, :model
  alias EducateYour.{Repo, Tagging, Tag}

  schema "tags" do
    field :context, :string
    field :text, :string
    timestamps()
    has_many :taggings, Tagging
  end

  ##
  # Changesets
  #

  def changeset(struct, params \\ %{}) do
    struct
      |> cast(params, [:context, :text])
      |> validate_required([:context, :text])
      |> validate_inclusion(:context, valid_contexts())
      |> validate_tag_has_no_special_chars
  end

  def validate_tag_has_no_special_chars(changeset) do
    text = get_field(changeset, :text)
    if String.match?(text, ~r/\A[\w\d ]+\z/) do
      changeset
    else
      add_error(changeset, :text, "Must only contain letters, numbers, and spaces.")
    end
  end

  ##
  # Helpers
  #

  def valid_contexts do
    ["location", "demographic", "topic", "sentiment"]
  end

  def find_or_create(params) do
    tag_changeset = Tag.changeset(%Tag{}, %{
      context: params["context"],
      text: params["text"]
    })
    cleaned_tag_params = %{
      context: get_change(tag_changeset, :context),
      text: get_change(tag_changeset, :text)}
    Repo.get_by(Tag, cleaned_tag_params) || Repo.insert!(tag_changeset)
  end
end
