defmodule RTL.Repo do
  use Ecto.Repo, otp_app: :rtl
  import Ecto.Query
  require Logger

  def count(query), do: query |> select([t], count(t.id)) |> one()
  def any?(query), do: count(query) >= 1
  def first(query), do: query |> limit(1) |> one()
  def first!(query), do: query |> limit(1) |> one!()

  def ensure_success(result) do
    case result do
      {:ok, object} -> object
      {:error, changeset} -> raise Ecto.InvalidChangesetError, changeset: changeset
    end
  end

  #
  # Describing changeset errors
  # (arguably doesn't belong in Repo)
  #

  # Assemble all this changeset's errors into a comma-separated summary.
  # e.g. "username can't be blank, password must be at most 20 characters"
  def describe_errors(changeset) do
    if length(changeset.errors) == 0, do: raise "This changeset has no errors to describe!"

    changeset
    |> inject_vars_into_error_messages()
    |> Enum.map(fn({field, errors}) -> "#{field} #{Enum.join(errors, " and ")}" end)
    |> Enum.join(", ")
    |> String.replace("(s)", "s")
  end

  defp inject_vars_into_error_messages(changeset) do
    Ecto.Changeset.traverse_errors(changeset, fn({msg, opts}) ->
      # e.g. input: {"must be at most %{count} chars", [count: 10, validation: ...]}
      #      output: "must be at most 3 chars"
      Enum.reduce(opts, msg, fn({key, value}, acc) ->
        String.replace(acc, "%{#{key}}", to_string(value))
      end)
    end)
  end

  #
  # Query logging
  #

  # Inspired by https://github.com/elixir-ecto/ecto/blob/v2.2.11/lib/ecto/log_entry.ex
  # (only relevant to Ecto v2!)
  # TODO: Clean this out and migrate to Ecto v3.
  def log_query(entry) do
    Logger.log(:debug, fn ->
      {ok, _} = entry.result
      source = if entry.source, do: " source=#{inspect(entry.source)}", else: ""
      time_us = System.convert_time_unit(entry.query_time, :native, :microsecond)
      time_ms = div(time_us, 100) / 10
      # Clean out redundant double quotes from query
      query = Regex.replace(~r/(\d\.)"([^"]+)"/, entry.query, "\\1\\2")

      params = Enum.map(entry.params, fn
        %Ecto.Query.Tagged{value: value} -> value
        value -> value
      end)

      "SQL query: #{ok}#{source} db=#{time_ms}ms   #{query}   params=#{inspect(params)}"
    end)
  end
end
