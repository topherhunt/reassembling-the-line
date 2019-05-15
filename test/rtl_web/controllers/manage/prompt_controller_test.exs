defmodule RTLWeb.Manage.PromptControllerTest do
  use RTLWeb.ConnCase, async: true
  alias RTL.Projects

  defp prompt_path(conn, action, proj) do
    Routes.manage_prompt_path(conn, action, proj)
  end

  defp prompt_path(conn, action, proj, prompt) do
    Routes.manage_prompt_path(conn, action, proj, prompt)
  end

  describe "plugs" do
    test "all actions reject if no user is logged in", %{conn: conn} do
      proj = Factory.insert_project()
      prompt = Factory.insert_prompt()

      conn = get(conn, prompt_path(conn, :edit, proj, prompt))

      assert redirected_to(conn) == Routes.home_path(conn, :index)
      assert conn.halted
    end

    test "all actions reject if you're an unauthorized user", %{conn: conn} do
      {conn, _user} = login_as_new_user(conn)
      proj = Factory.insert_project()
      prompt = Factory.insert_prompt()

      conn = get(conn, prompt_path(conn, :edit, proj, prompt))

      assert redirected_to(conn) == Routes.home_path(conn, :index)
      assert conn.halted
    end

    test "all actions allow you if you're an admin on this project", %{conn: conn} do
      {conn, user} = login_as_new_user(conn)
      proj = Factory.insert_project()
      prompt = Factory.insert_prompt()
      Projects.add_project_admin!(user, proj)

      conn = get(conn, prompt_path(conn, :edit, proj, prompt))

      assert html_response(conn, 200) =~ "test-page-edit-prompt-#{prompt.id}"
    end

    test "all actions allow you if you're a superadmin", %{conn: conn} do
      {conn, _user} = login_as_superadmin(conn)
      proj = Factory.insert_project()
      prompt = Factory.insert_prompt()

      conn = get(conn, prompt_path(conn, :edit, proj, prompt))

      assert html_response(conn, 200) =~ "test-page-edit-prompt-#{prompt.id}"
    end
  end

  describe "#new" do
    test "renders correctly", %{conn: conn} do
      {conn, _} = login_as_superadmin(conn)
      proj = Factory.insert_project()

      conn = get(conn, prompt_path(conn, :new, proj))

      assert html_response(conn, 200) =~ "test-page-new-prompt"
    end
  end

  describe "#create" do
    test "inserts the prompt and redirects", %{conn: conn} do
      {conn, _} = login_as_superadmin(conn)
      proj = Factory.insert_project()

      params = %{"prompt" => %{"html" => "My Second Prompt"}}
      conn = post(conn, prompt_path(conn, :create, proj), params)

      prompt = Projects.get_prompt_by!(order: :newest)
      assert prompt.project_id == proj.id
      assert prompt.html == "My Second Prompt"
      assert redirected_to(conn) == Routes.manage_project_path(conn, :show, proj)
    end

    test "rejects changes if invalid", %{conn: conn} do
      {conn, _user} = login_as_superadmin(conn)
      proj = Factory.insert_project()
      count = Projects.count_prompts()

      params = %{"prompt" => %{"html" => "   "}}
      conn = post(conn, prompt_path(conn, :create, proj), params)

      assert Projects.count_prompts() == count
      assert html_response(conn, 200) =~ "html can't be blank"
    end
  end

  describe "#edit" do
    test "renders correctly", %{conn: conn} do
      {conn, _user} = login_as_superadmin(conn)
      proj = Factory.insert_project()
      prompt = Factory.insert_prompt()

      conn = get(conn, prompt_path(conn, :edit, proj, prompt))

      assert html_response(conn, 200) =~ "test-page-edit-prompt-#{prompt.id}"
    end
  end

  describe "#update" do
    test "saves changes and redirects", %{conn: conn} do
      {conn, _user} = login_as_superadmin(conn)
      proj = Factory.insert_project()
      prompt = Factory.insert_prompt()

      params = %{"prompt" => %{"html" => "New prompt text"}}
      conn = patch(conn, prompt_path(conn, :update, proj, prompt), params)

      assert Projects.get_prompt!(prompt.id).html == "New prompt text"
      assert redirected_to(conn) == Routes.manage_project_path(conn, :show, proj)
    end

    test "rejects changes if invalid", %{conn: conn} do
      {conn, _user} = login_as_superadmin(conn)
      proj = Factory.insert_project()
      prompt = Factory.insert_prompt()

      params = %{"prompt" => %{"html" => "        "}}
      conn = patch(conn, prompt_path(conn, :update, proj, prompt), params)

      assert Projects.get_prompt!(prompt.id).html == prompt.html
      assert html_response(conn, 200) =~ "html can't be blank"
    end
  end

  describe "#delete" do
    test "deletes the prompt", %{conn: conn} do
      {conn, _user} = login_as_superadmin(conn)
      proj = Factory.insert_project()
      prompt = Factory.insert_prompt()

      conn = delete(conn, prompt_path(conn, :delete, proj, prompt))

      assert Projects.get_prompt(prompt.id) == nil
      assert redirected_to(conn) == Routes.manage_project_path(conn, :show, proj)
    end
  end
end
