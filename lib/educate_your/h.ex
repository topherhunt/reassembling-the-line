# Various helper methods to make a Rails dev feel more at home in Phoenix
defmodule EducateYour.H do
  def tap(input, function) do
    function.(input)
    input
  end

  # Example usage: |> H.tap("All segments found:", &Segment.debug_list/1)
  def tap(input, debug_msg, function) do
    IO.puts "====="
    IO.puts debug_msg
    function.(input)
    IO.puts "====="
    input
  end

  def is_blank?(value) do
    value == nil || value == ""
  end

  def human_time_to_integer(input) do
    string = (input || "")
      |> String.replace(~r/[^\d\:]+/, "", global: true)
      |> String.split(":")
    case string do
      [""] ->
        nil
      [minutes, seconds] ->
        (String.to_integer(minutes) * 60) + String.to_integer(seconds)
      [seconds] ->
        String.to_integer(seconds)
      _default ->
        raise "Don't know how to parse human time: #{input}"
    end
  end

  def integer_time_to_human(integer) do
    if integer do
      minutes = div(integer, 60)
      seconds = rem(integer, 60) |> Integer.to_string |> String.pad_leading(2, "0")
      "#{minutes}:#{seconds}"
    end
  end

  def random_hex do
    :crypto.strong_rand_bytes(4) |> Base.encode16
  end
end
