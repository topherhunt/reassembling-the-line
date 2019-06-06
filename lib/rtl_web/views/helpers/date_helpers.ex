defmodule RTLWeb.DateHelpers do
  use Phoenix.HTML

  def print_date(nil), do: nil

  def print_date(date, opts \\ []) do
    # See file:///Users/topher/.hex/docs/hexpm/timex/3.5.0/formatting.html
    Timex.format!(date, opts[:format] || "%b %d, %Y", :strftime)
  end
end
