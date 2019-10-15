defmodule RTLWeb.ConnHelpers do
  use Phoenix.ConnTest
  import RTL.Factory

  def login(conn, user) do
    conn |> assign(:current_user, user)
  end

  def login_as_new_user(conn, user_params \\ %{}) do
    user = insert_user(user_params)
    conn = login(conn, user)
    {conn, user}
  end

  def login_as_superadmin(conn) do
    login_as_new_user(conn, %{email: "superadmin@example.com"})
  end
end
