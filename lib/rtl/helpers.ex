defmodule RTL.Helpers do
  def env!(key), do: System.get_env(key) || raise("Env var '#{key}' is missing!")

  def is_blank?(value), do: value == nil || (is_binary(value) && String.trim(value) == "")

  def is_present?(value), do: !is_blank?(value)

  def assert_list_contains(list, item) do
    unless Enum.member?(list, item) do
      raise "List is missing expected item #{inspect(item)}. The list: #{inspect(list)}"
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
end
