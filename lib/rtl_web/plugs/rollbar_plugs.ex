defmodule RTLWeb.RollbarPlugs do
  # Rollbax request error reporter
  # See https://hexdocs.pm/rollbax/using-rollbax-in-plug-based-applications.html
  # and hexdocs for Rollbax#report/5
  def handle_errors(conn, %{kind: kind, reason: reason, stack: stacktrace}) do
    conn =
      conn
      |> Plug.Conn.fetch_cookies()
      |> Plug.Conn.fetch_query_params()

    params =
      case conn.params do
        %Plug.Conn.Unfetched{aspect: :params} -> "unfetched"
        other -> other
      end

    request_data = %{
      "request" => %{
        "cookies" => conn.req_cookies,
        "url" => "#{conn.scheme}://#{conn.host}:#{conn.port}#{conn.request_path}",
        "user_ip" => List.to_string(:inet.ntoa(conn.remote_ip)),
        "headers" => Enum.into(conn.req_headers, %{}),
        "method" => conn.method,
        "params" => params
      }
    }

    Rollbax.report(kind, reason, stacktrace, _custom_data = %{}, request_data)
  end
end
