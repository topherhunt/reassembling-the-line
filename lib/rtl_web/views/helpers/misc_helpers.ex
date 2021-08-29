defmodule RTLWeb.MiscHelpers do
  import RTLWeb.Gettext

  def required do
    Phoenix.HTML.raw " <span class='text-danger u-tooltip-target'>*<div class='u-tooltip u-tooltip-oneline'>#{gettext("Required")}</div></span>"
  end

  # TODO: Move all usages of this to RTL.Helpers.print_date
  def print_date(nil), do: nil
  def print_date(date, opts \\ []) do
    Timex.format!(date, opts[:format] || "%b %d, %Y", :strftime)
  end
end
