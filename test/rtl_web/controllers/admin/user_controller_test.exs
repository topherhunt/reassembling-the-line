defmodule RTLWeb.Admin.UserControllerTest do
  use RTLWeb.ConnCase, async: true
  alias RTL.Accounts

  describe "plugs" do
    test "all actions reject non-logged-in user", %{conn: conn} do
      conn = get(conn, Routes.admin_user_path(conn, :index))

      assert redirected_to(conn) == Routes.home_path(conn, :index)
      assert conn.halted
    end

    test "all actions reject non-superadmin", %{conn: conn} do
      {conn, _user} = login_as_new_user(conn, %{email: "normal-guy@example.com"})

      conn = get(conn, Routes.admin_user_path(conn, :index))

      assert redirected_to(conn) == Routes.home_path(conn, :index)
      assert conn.halted
    end
  end

  describe "#index" do
    test "lists all users", %{conn: conn} do
      {conn, _user} = login_as_superadmin(conn)
      user1 = Factory.insert_user()
      user2 = Factory.insert_user()

      conn = get(conn, Routes.admin_user_path(conn, :index))

      assert html_response(conn, 200)
      assert conn.resp_body =~ user1.full_name
      assert conn.resp_body =~ user2.full_name
    end
  end

  describe "#show" do
    test "renders correctly", %{conn: conn} do
      {conn, _user} = login_as_superadmin(conn)
      user = Factory.insert_user()

      conn = get(conn, Routes.admin_user_path(conn, :show, user))

      assert html_response(conn, 200) =~ user.full_name
    end
  end

  describe "#new" do
    test "renders correctly", %{conn: conn} do
      {conn, _user} = login_as_superadmin(conn)

      conn = get(conn, Routes.admin_user_path(conn, :new))

      assert html_response(conn, 200) =~ "New user"
    end
  end

  describe "#create" do
    test "inserts the user and redirects", %{conn: conn} do
      {conn, _user} = login_as_superadmin(conn)
      count = Accounts.count_users()

      params = %{"user" => %{"full_name" => "E. Fudd", "email" => "elmer@fudd.com"}}
      conn = post(conn, Routes.admin_user_path(conn, :create), params)

      assert Accounts.count_users() == count + 1
      user = Accounts.get_user_by!(order: :newest)
      assert user.full_name == "E. Fudd"
      assert user.email == "elmer@fudd.com"
      assert redirected_to(conn) == Routes.admin_user_path(conn, :show, user.id)
    end

    test "rejects changes if invalid", %{conn: conn} do
      {conn, _user} = login_as_superadmin(conn)
      count = Accounts.count_users()

      params = %{"user" => %{"full_name" => "   ", "email" => "elmer@fudd.com"}}
      conn = post(conn, Routes.admin_user_path(conn, :create), params)

      assert Accounts.count_users() == count
      assert html_response(conn, 200) =~ "full_name can't be blank"
    end
  end

  describe "#edit" do
    test "renders correctly", %{conn: conn} do
      {conn, _user} = login_as_superadmin(conn)
      user = Factory.insert_user()

      conn = get(conn, Routes.admin_user_path(conn, :edit, user))

      assert html_response(conn, 200) =~ "Edit user: #{user.full_name}"
    end
  end

  describe "#update" do
    test "saves changes and redirects", %{conn: conn} do
      {conn, _user} = login_as_superadmin(conn)
      user = Factory.insert_user()

      params = %{"user" => %{"full_name" => "Daffy", "email" => "daffy@duck.com"}}
      conn = patch(conn, Routes.admin_user_path(conn, :update, user.id), params)

      updated = Accounts.get_user!(user.id)
      assert updated.full_name == "Daffy"
      assert updated.email == "daffy@duck.com"
      assert redirected_to(conn) == Routes.admin_user_path(conn, :show, user)
    end

    test "rejects changes if invalid", %{conn: conn} do
      {conn, _user} = login_as_superadmin(conn)
      user = Factory.insert_user()

      params = %{"user" => %{"full_name" => " ", "email" => "daffy@duck.com"}}
      conn = patch(conn, Routes.admin_user_path(conn, :update, user), params)

      unchanged = Accounts.get_user!(user.id)
      assert unchanged.full_name == user.full_name
      assert html_response(conn, 200) =~ "name can't be blank"
    end
  end

  describe "#delete" do
    test "deletes the user", %{conn: conn} do
      {conn, _user} = login_as_superadmin(conn)
      user = Factory.insert_user()

      conn = delete(conn, Routes.admin_user_path(conn, :delete, user))

      assert Accounts.get_user(user.id) == nil
      assert redirected_to(conn) == Routes.admin_user_path(conn, :index)
    end
  end
end
