defmodule EducateYourWeb.ConnHelpers do
  use Phoenix.ConnTest
  import EducateYour.Factory

  # NOTE: Only works on functional tests, not integration tests.
  def login_as_new_user(conn, user_params \\ %{}) do
    user = insert_user(user_params)
    conn = conn |> assign(:current_user, user)
    {conn, user}
  end
end
