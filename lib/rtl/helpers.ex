defmodule RTL.Helpers do
  def env!(key), do: System.get_env(key) || raise("Env var '#{key}' is missing!")

  def is_blank?(value), do: value == nil || (is_binary(value) && String.trim(value) == "")

  def is_present?(value), do: !is_blank?(value)

  # Render any value as a string for debugging (without printing to IO)
  # TODO: What value does this provide that inspect(obj) doesn't provide?
  # Does it do wrapping of long lines in giant structs or something?
  def stringify(input) do
    input
    |> Inspect.Algebra.to_doc(%Inspect.Opts{})
    |> Inspect.Algebra.format(100)
    |> Enum.join("")
  end

  def assert_list_contains(list, item) do
    unless Enum.member?(list, item) do
      raise "Expected list to contain item #{stringify(item)}, but it isn't there. " <>
              "The list: #{stringify(list)}"
    end
  end
end
