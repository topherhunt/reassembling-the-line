defmodule EducateYour.Tag do
  use EducateYour.Web, :model

  schema "tags" do
    field :context, :string
    field :text, :string
    timestamps()
    has_many :taggings, EducateYour.Tagging
  end

  # === Changesets ===

  def changeset(struct, params \\ %{}) do
    struct
      |> cast(params, [:context, :text])
      |> validate_required([:context, :text])
      |> validate_inclusion(:context, valid_contexts())
      |> validate_text_has_no_special_chars
  end

  def valid_contexts do
    ["location", "demographic", "topic", "sentiment"]
  end

  def validate_text_has_no_special_chars(changeset) do
    TODO
  end
end
