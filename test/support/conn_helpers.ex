defmodule EducateYour.ConnHelpers do
  use Phoenix.ConnTest
  import EducateYour.Factory

  def login_as_new_user(conn, user_opts \\ %{}) do
    user = insert :user, user_opts
    conn = conn |> assign(:current_user, user)
    {conn, user}
  end
end
