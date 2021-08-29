defmodule RTLWeb.Admin.UserControllerTest do
  use RTLWeb.ConnCase, async: true

  describe "plugs" do
    test "all actions reject non-logged-in user", %{conn: conn} do
      conn = get(conn, Routes.admin_user_path(conn, :index))

      assert redirected_to(conn) == Routes.auth_path(conn, :login)
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
      assert conn.resp_body =~ user1.name
      assert conn.resp_body =~ user2.name
    end
  end

  describe "#show" do
    test "renders correctly", %{conn: conn} do
      {conn, _user} = login_as_superadmin(conn)
      user = Factory.insert_user()

      conn = get(conn, Routes.admin_user_path(conn, :show, user))

      assert html_response(conn, 200) =~ user.name
    end
  end

  # Admin creating new users is disabled for now, and probably not needed.
  #
  # describe "#new" do
  #   test "renders correctly", %{conn: conn} do
  #     {conn, _user} = login_as_superadmin(conn)
  #
  #     conn = get(conn, Routes.admin_user_path(conn, :new))
  #
  #     assert html_response(conn, 200) =~ "New user"
  #   end
  # end

  # describe "#create" do
  #   test "inserts the user and redirects", %{conn: conn} do
  #     {conn, _user} = login_as_superadmin(conn)
  #     count = Repo.count(User)
  #
  #     params = %{"user" => %{"name" => "E. Fudd", "email" => "elmer@fudd.com"}}
  #     conn = post(conn, Routes.admin_user_path(conn, :create), params)
  #
  #     assert Repo.count(User) == count + 1
  #     user = Repo.first!(User.filter(order: :newest))
  #     assert user.name == "E. Fudd"
  #     assert user.email == "elmer@fudd.com"
  #     assert redirected_to(conn) == Routes.admin_user_path(conn, :show, user.id)
  #   end
  #
  #   test "rejects changes if invalid", %{conn: conn} do
  #     {conn, _user} = login_as_superadmin(conn)
  #     count = Repo.count(User)
  #
  #     params = %{"user" => %{"name" => "   ", "email" => "elmer@fudd.com"}}
  #     conn = post(conn, Routes.admin_user_path(conn, :create), params)
  #
  #     assert Repo.count(User) == count
  #     assert html_response(conn, 200) =~ "name can't be blank"
  #   end
  # end

  describe "#edit" do
    test "renders correctly", %{conn: conn} do
      {conn, _user} = login_as_superadmin(conn)
      user = Factory.insert_user()

      conn = get(conn, Routes.admin_user_path(conn, :edit, user))

      assert html_response(conn, 200) =~ "Edit user: #{user.name}"
    end
  end

  describe "#update" do
    test "saves changes and redirects", %{conn: conn} do
      {conn, _user} = login_as_superadmin(conn)
      user = Factory.insert_user()

      params = %{"user" => %{"name" => "Daffy", "email" => "daffy@duck.com"}}
      conn = patch(conn, Routes.admin_user_path(conn, :update, user.id), params)

      updated = Repo.get!(User, user.id)
      assert updated.name == "Daffy"
      assert updated.email == "daffy@duck.com"
      assert redirected_to(conn) == Routes.admin_user_path(conn, :show, user)
    end

    test "rejects changes if invalid", %{conn: conn} do
      {conn, _user} = login_as_superadmin(conn)
      user = Factory.insert_user()

      params = %{"user" => %{"name" => " ", "email" => "daffy@duck.com"}}
      conn = patch(conn, Routes.admin_user_path(conn, :update, user), params)

      unchanged = Repo.get!(User, user.id)
      assert unchanged.name == user.name
      assert html_response(conn, 200) =~ "name can't be blank"
    end
  end

  describe "#delete" do
    test "deletes the user", %{conn: conn} do
      {conn, _user} = login_as_superadmin(conn)
      user = Factory.insert_user()

      conn = delete(conn, Routes.admin_user_path(conn, :delete, user))

      assert Repo.get(User, user.id) == nil
      assert redirected_to(conn) == Routes.admin_user_path(conn, :index)
    end
  end
end
