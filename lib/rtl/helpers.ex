defmodule RTL.Helpers do

  #
  # Env
  #

  def env(key), do: System.get_env(key) || nil
  def env!(key), do: System.get_env(key) || raise("Env var '#{key}' is missing!")

  def memory_mb, do: Float.round(:erlang.memory[:total] / 1_000_000.0, 3)

  #
  # Maps
  #

  def invert_map(map), do: Map.new(map, fn {k, v} -> {v, k} end)

  # If the map/struct is present, returns (and requires) the specified field.
  def try(%{} = map, field), do: Map.fetch!(map, field)
  def try(nil, _), do: nil

  # Useful for asserting the shape of all values in a list.
  # Example: Enum.each(badges, & H.assert_struct(&1, %Badge{}))
  def assert_struct(%{} = actual, %{} = expected) do
    unless actual.__struct__ == expected.__struct__ do
      raise "Expected struct %#{expected.__struct__}{}, got #{inspect actual}"
    end
  end

  def assert_keys(map_or_kw_list, opts) do
    actual_keys = map_or_kw_list |> Enum.into(%{}) |> Map.keys()
    required_keys = opts[:required] || []
    allowed_keys = (opts[:allowed] || []) ++ required_keys

    Enum.each(required_keys, fn key ->
      unless key in actual_keys, do: raise "Required key is absent: #{inspect(key)}"
    end)

    Enum.each(actual_keys, fn key ->
      unless key in allowed_keys, do: raise "Key is not allowed: #{inspect(key)}."
    end)
  end

  #
  # Structs
  #

  def persisted?(struct), do: struct.__meta__.state == :loaded

  #
  # Strings
  #

  def blank?(nil), do: true
  def blank?(string) when is_binary(string), do: String.trim(string) == ""

  def present?(string), do: !blank?(string)

  def presence(string), do: if present?(string), do: string, else: nil

  def to_hash(string), do: :crypto.hash(:md5, string) |> Base.encode16()

  #
  # Integers
  #

  def to_int(nil), do: nil
  def to_int(int) when is_integer(int), do: int
  def to_int(string) when is_binary(string), do: String.to_integer(string)

  # This is a more expressive way to say "don't allow a number less than X"
  def at_least(a, b), do: max(a, b)

  #
  # Dates
  #

  def today, do: Date.utc_today()

  def to_date(nil), do: nil
  def to_date(%DateTime{} = dt), do: DateTime.to_date(dt)
  def to_date(%NaiveDateTime{} = dt), do: DateTime.to_date(dt)

  def date_gt?(a, b), do: Date.compare(a, b) == :gt # returns true if A > B
  def date_lt?(a, b), do: Date.compare(a, b) == :lt # returns true if A < B
  def date_gte?(a, b), do: Date.compare(a, b) in [:gt, :eq] # true if A >= B
  def date_lte?(a, b), do: Date.compare(a, b) in [:lt, :eq] # true if A <= B
  def date_between?(date, a, b), do: date_gte?(date, a) && date_lte?(date, b)

  #
  # Datetimes
  #

  def now, do: DateTime.utc_now()

  def datetime_gt?(a, b), do: datetime_compare(a, b) == :gt # returns true if A > B
  def datetime_lt?(a, b), do: datetime_compare(a, b) == :lt # returns true if A < B
  def datetime_gte?(a, b), do: datetime_compare(a, b) in [:gt, :eq] # true if A >= B
  def datetime_lte?(a, b), do: datetime_compare(a, b) in [:lt, :eq] # true if A <= B
  def datetime_between?(dt, a, b), do: datetime_gte?(dt, a) && datetime_lte?(dt, b)

  def datetime_compare(a, b), do: DateTime.compare(to_datetime(a), to_datetime(b))

  def to_datetime(%NaiveDateTime{} = dt), do: DateTime.from_naive!(dt, "Etc/UTC")
  def to_datetime(dt), do: dt

  def beginning_of_day(%Date{} = d), do: d |> Timex.to_datetime() |> beginning_of_day()
  def beginning_of_day(%DateTime{} = dt), do: dt |> Timex.beginning_of_day()

  def end_of_day(%Date{} = d), do: d |> Timex.to_datetime() |> end_of_day()
  def end_of_day(%DateTime{} = dt), do: dt |> Timex.end_of_day()

  def days_ago(n) when is_integer(n), do: now() |> Timex.shift(days: -n)
  def in_days(n) when is_integer(n), do: now() |> Timex.shift(days: n)

  def hours_ago(n) when is_integer(n), do: now() |> Timex.shift(hours: -n)
  def in_hours(n) when is_integer(n), do: now() |> Timex.shift(hours: n)

  def mins_ago(n) when is_integer(n), do: now() |> Timex.shift(minutes: -n)
  def in_mins(n) when is_integer(n), do: now() |> Timex.shift(minutes: n)

  #
  # Datetime formatting
  #

  # See https://hexdocs.pm/timex/Timex.Format.DateTime.Formatters.Strftime.html
  def print_datetime(datetime, format \\ "%Y-%m-%d %l:%M %P UTC") do
    if datetime, do: Timex.format!(datetime, format, :strftime)
  end

  def print_date(datetime, format \\ "%Y-%m-%d"), do: print_datetime(datetime, format)

  def print_time(datetime, format \\ "%l:%M %P"), do: print_datetime(datetime, format)

end
