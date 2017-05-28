# Script for populating the database. You can run it as:
# > mix run priv/repo/seeds.exs

defmodule Helpers do
  def in_days(n) do
    Timex.today |> Timex.shift(days: n)
  end
end

import EducateYour.Factory

# TODO: Write seeds in here
