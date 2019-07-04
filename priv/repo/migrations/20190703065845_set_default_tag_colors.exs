defmodule RTL.Repo.Migrations.SetDefaultTagColors do
  use Ecto.Migration
  alias RTL.Videos.Tag

  def up do
    Tag.all() |> Enum.each(fn(tag) ->
      Tag.update!(tag, %{color: Tag.random_color()})
    end)

    alter table(:tags) do
      modify :color, :string, null: false
    end
  end
end
