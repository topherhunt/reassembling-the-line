defmodule RTLWeb.DateHelpers do
  use Phoenix.HTML

  def print_date(nil), do: nil
  def print_date(date, opts \\ []) do
    Timex.format!(date, opts[:format] || "%b %d, %Y", :strftime)
  end
end
