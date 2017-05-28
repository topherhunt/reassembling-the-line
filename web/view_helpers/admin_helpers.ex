defmodule EducateYour.AdminHelpers do
  use Phoenix.HTML

  def true_or_false_indicator(value) do
    if value do
      "<span class='text-success'>true</span>"
    else
      "<span class='text-warning'>false</span>"
    end |> raw
  end
end
