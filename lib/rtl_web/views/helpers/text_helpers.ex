defmodule RTLWeb.TextHelpers do
  use Phoenix.HTML

  def ellipsis(text, length) do
    if String.length(text) > length - 3 do
      String.slice(text, 0..length) <> "..."
    else
      text
    end
  end
end
