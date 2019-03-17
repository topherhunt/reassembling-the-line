defmodule RTL.Helpers do
  #
  # Env vars
  #

  def env(key), do: System.get_env(key) || raise("Env var '#{key}' is missing!")

  #
  # Pipes
  #

  # Pro tip: `IO.inspect(item, label: "My cat's age:")` can be inserted into a pipe!
  # See https://hexdocs.pm/elixir/IO.html#inspect/2

  #
  # Strings
  #

  # Renders any value as a string for debugging (without printing to IO)
  def stringify(input) do
    input
    |> Inspect.Algebra.to_doc(%Inspect.Opts{})
    |> Inspect.Algebra.format(100)
    |> Enum.join("")
  end

  def is_blank?(value) do
    value == nil ||
      (is_binary(value) && String.trim(value) == "")
  end

  def is_present?(value), do: !is_blank?(value)

  def random_hex do
    :crypto.strong_rand_bytes(4) |> Base.encode16()
  end

  #
  # Lists
  #

  def assert_list_contains(list, item) do
    unless Enum.member?(list, item) do
      raise "Expected list to contain item #{stringify(item)}, but it isn't there. " <>
              "The list: #{stringify(list)}"
    end
  end

  # TODO: It would be nice to have some helpers to assert that each item in a list
  # pattern-matches the expected format. After some brief testing, this didn't seem
  # to be easy.
  #
  # def each_matches?(list, pattern) do
  #   Enum.all?(list, fn(item) -> match?(pattern, item) end)
  # end
  #
  # def assert_each_matches(list, pattern) do
  #   Enum.each(list, fn(item) ->
  #     unless match?(pattern, item) do
  #       raise "Found an item in the list that doesn't match the pattern! The pattern: #{pattern}, the item: #{item}"
  #     end
  #   end)
  # end
end
