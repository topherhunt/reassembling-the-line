# One-line full request logging inspired by Plug.Logger.
# See https://github.com/elixir-plug/plug/blob/v1.8.0/lib/plug/logger.ex
# Need to restart the server after updating this file.
defmodule RTLWeb.RequestLogger do
  require Logger

  @behaviour Plug

  def init(opts) do
    %{log_level: opts[:log_level] || :info}
  end

  def call(conn, opts) do
    start_time = System.monotonic_time()

    Plug.Conn.register_before_send(conn, fn(conn) ->
      # Uses a func so the string doesn't need to be computed unless log_level is active.
      # Charlist would be more performant, but I'm not pro enough to worry about that.
      # Other data I could include, but feels redundant: remote_ip, port, owner (PID).
      Logger.log(
        opts.log_level,
        fn ->
          "■ [#{conn.method} #{conn.request_path}] "<>
          "params=#{inspect(Phoenix.Logger.filter_values(conn.params))} "<>
          "user=#{print_user(conn)} "<>
          "status=#{conn.status}#{print_redirect(conn)} "<>
          "duration=#{print_time_taken(start_time)}"
        end)
      conn
    end)
  end

  defp print_user(conn) do
    if conn.assigns.current_user do
      "#{conn.assigns.current_user.id} (#{conn.assigns.current_user.full_name})"
    else
      "(none)"
    end
  end

  defp print_redirect(conn) do
    if conn.status == 302 do
      " redirected_to=#{Plug.Conn.get_resp_header(conn, "location")}"
    else
      ""
    end
  end

  defp print_time_taken(start_time) do
    stop_time = System.monotonic_time()
    microsecs = System.convert_time_unit(stop_time - start_time, :native, :microsecond)

    if microsecs > 1000 do
      [microsecs |> div(1000) |> Integer.to_string(), "ms"]
    else
      [Integer.to_string(microsecs), "µs"]
    end
  end
end
