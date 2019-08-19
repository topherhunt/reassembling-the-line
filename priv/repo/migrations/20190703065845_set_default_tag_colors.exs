defmodule RTL.Repo.Migrations.SetDefaultTagColors do
  use Ecto.Migration
  import Ecto.Query
  alias RTL.Repo
  alias RTL.Videos.Tag

  def up do
    # Populate color for all existing tags.
    # Can't reference the schema or changeset because fields may have changed since this
    # point in the migrations timeline.
    from(t in Tag, select: t.id)
    |> Repo.all()
    |> Enum.each(fn(tag_id) ->
      execute("UPDATE tags SET color='#{Tag.random_color()}' WHERE id=#{tag_id}")
    end)

    alter table(:tags) do
      modify :color, :string, null: false
    end
  end
end
