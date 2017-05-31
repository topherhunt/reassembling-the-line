defmodule EducateYour.ExploreControllerTest do
  use EducateYour.ConnCase, async: true

  test "#index renders the page (no login needed)", %{conn: conn} do
    conn = get(conn, explore_path(conn, :index))
    assert html_response(conn, 200) =~ "Explore"
  end
end
