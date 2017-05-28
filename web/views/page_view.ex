defmodule Zb.PageView do
  use Zb.Web, :view

  def faculty_inserted_at(faculty) do
    if Enum.any?(faculty) do
      List.first(faculty).inserted_at |> Timex.format!("{ISO:Extended}")
    end
  end
end
