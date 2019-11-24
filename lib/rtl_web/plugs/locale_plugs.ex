defmodule RTLWeb.LocalePlugs do
  import Plug.Conn, only: [get_session: 2, get_req_header: 2, put_session: 3, halt: 1]
  import Phoenix.Controller, only: [redirect: 2]

  # Decide what locale this request should use.
  # If it's given in a GET param, store it in the session and refresh to clear the param.
  # If it's set in the session, use that. Otherwise fall back to the browser setting or en.
  def detect_locale(conn, _opts) do
    if locale = conn.params["locale"] do
      conn
      |> put_session(:locale, locale)
      |> redirect(to: conn.request_path)
      |> halt()
    else
      session_locale = get_session(conn, :locale)
      browser_locale = get_req_header(conn, "Accept-Language") |> List.first()
      locale = whitelist(session_locale) || whitelist(browser_locale) || "en"

      Gettext.put_locale(RTLWeb.Gettext, locale)
      conn
    end
  end

  defp whitelist(locale) do
    if locale in Gettext.known_locales(RTLWeb.Gettext), do: locale
  end
end
