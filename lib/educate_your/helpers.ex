defmodule EducateYour.Helpers do

  #
  # Env vars
  #

  def env(key), do: System.get_env(key) || raise("Env var '#{key}' is missing!")

  #
  # Pipes
  #

  def inspect(input, description \\ "The piped value:") do
    IO.puts description
    IO.inspect input
    input
  end

  #
  # String
  #

  def is_blank?(value) do
    (value == nil) ||
    (is_binary(value) && String.trim(value) == "")
  end

  def is_present?(value) do
    !is_blank?(value)
  end

  def random_hex do
    :crypto.strong_rand_bytes(4) |> Base.encode16
  end

  #
  # Time
  #

  def time_to_integer(input) do
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

  def integer_to_time(integer) do
    if integer do
      minutes = div(integer, 60)
      seconds = rem(integer, 60) |> Integer.to_string |> String.pad_leading(2, "0")
      "#{minutes}:#{seconds}"
    end
  end
end
