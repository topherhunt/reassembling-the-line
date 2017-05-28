defmodule EducateYour.ValidationHelpers do
  use ExUnit.CaseTemplate

  alias EducateYour.Repo

  # === How to use these validation helpers ===
  # Call assert_validates functions as relevant, passing the struct, changeset
  #   function name, field, and any other options
  # `struct` must be a valid, unpersisted struct with association _id fields
  #   populated (i.e. all fields expected by the changeset).
  #   build_with_assocs/2 is useful here.

  def assert_validates_presence(struct, changeset_name, field) do
    assert_valid(struct, changeset_name, params_from(struct), "given default struct")
    assert_invalid(struct, changeset_name,
      params_from(struct, %{field => ""}),
      "#{field} is blank")
  end

  def assert_validates_length(struct, changeset_name, field, minmax) do
    assert_valid(struct, changeset_name, params_from(struct), "given default struct")
    if minmax[:min] do
      assert_valid(struct, changeset_name,
        %{field => String.duplicate("a", minmax[:min])},
        "#{field} length >= #{minmax[:min]}")
      assert_invalid(struct, changeset_name,
        %{field => String.duplicate("a", minmax[:min] - 1)},
        "#{field} length <= #{minmax[:min] - 1}")
      if minmax[:min] > 0 do
        # If there's a minimum length, also ensure that blanks are invalid
        assert_validates_presence(struct, changeset_name, field)
      end
    end
    if minmax[:max] do
      assert_valid(struct, changeset_name,
        %{field => String.duplicate("a", minmax[:max])},
        "#{field} length <= #{minmax[:max]}")
      assert_invalid(struct, changeset_name,
        %{field => String.duplicate("a", minmax[:max] + 1)},
        "#{field} length >= #{minmax[:max] + 1}")
    end
  end

  def assert_validates_uniqueness(struct, changeset_name, field) do
    assert_valid(struct, changeset_name, params_from(struct), "given default struct")
    module = struct.__struct__
    changeset = apply(module, changeset_name, [struct, %{}])
    Repo.insert(changeset) # persist to the database (ignore failures)
    { :error, changeset } = Repo.insert(changeset) # now try to insert a 2nd copy
    assert { field, { "has already been taken", [] } } in changeset.errors
  end

  def assert_validates_inclusion(struct, changeset_name, field, values_map) do
    assert_valid_and_invalid_values(struct, changeset_name, field, values_map)
  end

  # === Internal helpers ===

  defp assert_valid_and_invalid_values(struct, changeset_name, field, %{valids: valids, invalids: invalids}) do
    Enum.each(valids, fn(value) ->
      assert_valid(struct, changeset_name,
        params_from(struct, %{field => value}),
        "when #{field} = #{value}")
    end)
    Enum.each(invalids, fn(value) ->
      assert_invalid(struct, changeset_name,
        params_from(struct, %{field => value}),
        "when #{field} = #{value}")
    end)
  end

  defp assert_valid(struct, changeset_name, params, condition) do
    module = struct.__struct__
    changeset = apply(module, changeset_name, [struct, params])
    assert changeset.valid?, "Expected #{module_name(module)}.#{changeset_name} to be valid when #{condition}, but it's invalid."
  end

  defp assert_invalid(struct, changeset_name, params, condition) do
    module = struct.__struct__
    changeset = apply(module, changeset_name, [struct, params])
    refute changeset.valid?, "Expected #{module_name(module)}.#{changeset_name} to be invalid when #{condition}, but it's valid."
  end

  defp params_from(struct, changes \\ %{}) do
    struct |> Map.from_struct |> Map.merge(changes)
  end

  defp module_name(module) do
    module |> to_string |> String.replace("Elixir.", "")
  end

end
