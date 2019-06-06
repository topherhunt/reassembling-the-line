defmodule RTLWeb.RouteHelpers do
  use Phoenix.HTML
  alias RTLWeb.Router.Helpers, as: Routes

  def contact_us_url do
    "https://docs.google.com/forms/d/e/1FAIpQLScFmkgOIWIN3QKIT1TI6e2A440ixtfMsAQ04kVoh85TLDmbXw/viewform?usp=sf_link"
  end

  def active_if_current(conn, path) do
    # IO.inspect(conn, label: "The conn")
    if conn.request_path == path, do: "active"
  end

  def navbar_logo_url(project) do
    RTLWeb.TextHelpers.project_setting(project, "navbar_logo_url") ||
      Routes.explore_project_path(RTLWeb.Endpoint, :show, project)
  end
end
