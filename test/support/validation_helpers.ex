defmodule EducateYour.ValidationHelpers do
  use ExUnit.CaseTemplate

  def assert_valid(module, changeset_name, default_params, changes \\ %{}) do
    params = Map.merge(default_params, changes)
    changeset = apply(module, changeset_name, [struct(module), params])
    assert changeset.valid?, "Expected #{module_name(module)}.#{changeset_name} to be valid, but it's invalid. The changeset: #{inspect(changeset)}"
  end

  def assert_invalid(module, changeset_name, default_params, changes \\ %{}) do
    params = Map.merge(default_params, changes)
    changeset = apply(module, changeset_name, [struct(module), params])
    assert !changeset.valid?, "Expected #{module_name(module)}.#{changeset_name} to be invalid, but it's valid. The changeset: #{inspect(changeset)}"
  end

  defp module_name(module) do
    module |> to_string |> String.replace("Elixir.", "")
  end
end
