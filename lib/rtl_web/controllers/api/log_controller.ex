defmodule RTLWeb.Api.LogController do
  use RTLWeb, :controller

  # Bare endpoint for logging updates on client-side state, to help me troubleshoot
  # errors that happen on pages with complex JS UIs.
  def log(conn, _params) do
    text(conn, "OK, thanks!")
  end
end
