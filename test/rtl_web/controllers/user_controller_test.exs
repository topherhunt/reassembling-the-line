defmodule RTLWeb.UserControllerTest do
  use RTLWeb.ConnCase
  alias RTL.Accounts

  describe "#edit" do
    test "renders the form", %{conn: conn} do
      {conn, user} = login_as_new_user(conn)

      conn = get(conn, Routes.user_path(conn, :edit))

      assert_content(conn, "Your profile")
      assert_content(conn, user.email)
    end
  end

  describe "#update" do
    test "updates the user and redirects to home", %{conn: conn} do
      {conn, user} = login_as_new_user(conn, %{name: "Original name"})

      user_params = %{name: "New name"}
      conn = patch(conn, Routes.user_path(conn, :update), %{user: user_params})

      assert Accounts.get_user!(user.id).name == "New name"
      assert redirected_to(conn) == Routes.user_path(conn, :edit)
    end

    test "rejects and re-renders the form when inputs are invalid", %{conn: conn} do
      {conn, user} = login_as_new_user(conn, %{name: "Original name"})

      user_params = %{name: ""}
      conn = patch(conn, Routes.user_path(conn, :update), %{user: user_params})

      assert Accounts.get_user!(user.id).name == "Original name"
      assert html_response(conn, 200) =~ "can't be blank"
    end
  end
end
