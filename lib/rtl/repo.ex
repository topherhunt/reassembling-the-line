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

  # Inspired by https://github.com/elixir-ecto/ecto/blob/v2.2.11/lib/ecto/log_entry.ex
  # (only relevant to Ecto v2!)
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
