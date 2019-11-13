# Note: In the future we may need to support defining one custom_block per project, per
# label, per __locale__. I don't think it would be hard to add support for that.
#
defmodule RTL.Projects.CustomBlock do
  use Ecto.Schema
  import Ecto.Changeset
  import Ecto.Query

  schema "custom_blocks" do
    belongs_to :project, RTL.Projects.Project
    field :label, :string
    field :body, :string
    timestamps()
  end

  def changeset(struct, params) do
    struct
    |> cast(params, [:project_id, :label, :body])
    |> validate_required([:project_id, :label])
    |> validate_inclusion(:label, Enum.map(templates(), & &1.label))
  end

  #
  # Filters
  #

  def apply_filters(starting_query, filters) do
    Enum.reduce(filters, starting_query, fn {k, v}, query -> filter(query, k, v) end)
  end

  def filter(query, :id, id), do: where(query, [p], p.id == ^id)
  def filter(query, :project, proj), do: where(query, [p], p.project_id == ^proj.id)
  def filter(query, :label, label), do: where(query, [p], p.label == ^label)

  #
  # Templates
  #

  def templates do
    [
      %{label: "custom_css", description: "CSS applied to all pages for this project"},
      %{label: "navbar_logo", description: "Replaces the default \"RTL\" logo link"},
      %{label: "footer", description: "The full footer (replaces ALL default links)"},
      %{label: "landing_page", description: "The full project landing page, incl. title"},
      %{label: "recording_page_intro", description: "Title & intro paragraph(s) at the top of the webcam recording page"},
      %{label: "recording_page_consent_text", description: "Content for the consent box at the bottom of the recording page. Note: this should identify the target audience that the speaker is consenting for their video to be shown to!"},
      %{label: "thank_you_page", description: "The full post-recording thank you page, incl. title"}
    ]
  end
end
