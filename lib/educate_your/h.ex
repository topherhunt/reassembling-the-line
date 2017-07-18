##
# Various helper methods to make a Rails dev feel more at home in Phoenix
#
defmodule EducateYour.H do
  def is_blank?(value) do
    value == nil || value == ""
  end

  def human_time_to_integer(human) do
    case String.split(human || "", ":") do
      [""] ->
        nil
      [minutes, seconds] ->
        (String.to_integer(minutes) * 60) + String.to_integer(seconds)
      [seconds] ->
        String.to_integer(seconds)
      _default ->
        raise "Don't know how to parse human time: #{human}"
    end
  end

  def integer_time_to_human(integer) do
    if integer do
      minutes = div(integer, 60)
      seconds = rem(integer, 60) |> Integer.to_string |> String.pad_leading(2, "0")
      "#{minutes}:#{seconds}"
    end
  end
end
