defmodule Zb.Tag do
  use Zb.Web, :model

  schema "tags" do
    field :text, :string # unique indexed
    field :recommended, :boolean
    timestamps()
    has_many :vote_taggings, Zb.VoteTagging
  end

  def admin_changeset(struct, params \\ %{}) do
    struct
      |> cast(params, [:text, :recommended])
      |> standardize_text(:text)
      |> validate_required([:text])
      |> unique_constraint(:text)
  end

  def voter_changeset(struct, params \\ %{}) do
    struct
      |> cast(params, [:text]) # voter shouldn't be able to change `recommended`
      |> standardize_text(:text)
      |> validate_required([:text])
      |> unique_constraint(:text)
  end

  defp standardize_text(changeset, field) do
    if value = changeset.changes[field] do
      new_value = value |> String.downcase |> String.replace(",", "")
      put_change(changeset, field, new_value)
    else
      changeset
    end
  end
end
