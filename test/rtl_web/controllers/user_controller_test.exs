defmodule RTLWeb.UserControllerTest do
  use RTLWeb.ConnCase
  alias RTL.Accounts

  describe "#edit" do
    test "renders the form", %{conn: conn} do
      {conn, user} = login_as_new_user(conn)

      conn = get(conn, Routes.user_path(conn, :edit))

      assert html_response(conn, 200) =~ "My profile"
      assert conn.resp_body =~ user.email
    end
  end

  describe "#update" do
    test "updates the user and redirects to home", %{conn: conn} do
      {conn, user} = login_as_new_user(conn, %{full_name: "Original name"})

      user_params = %{full_name: "New name"}
      conn = patch(conn, Routes.user_path(conn, :update), %{user: user_params})

      assert Accounts.get_user!(user.id).full_name == "New name"
      assert redirected_to(conn) == Routes.home_path(conn, :index)
    end

    test "rejects and re-renders the form when inputs are invalid", %{conn: conn} do
      {conn, user} = login_as_new_user(conn, %{full_name: "Original name"})

      user_params = %{full_name: ""}
      conn = patch(conn, Routes.user_path(conn, :update), %{user: user_params})

      assert Accounts.get_user!(user.id).full_name == "Original name"
      assert html_response(conn, 200) =~ "can't be blank"
    end
  end
end
