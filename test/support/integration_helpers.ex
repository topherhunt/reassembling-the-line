defmodule RTLWeb.IntegrationHelpers do
  use ExUnit.CaseTemplate
  # See https://github.com/HashNuke/hound for docs
  use Hound.Helpers
  alias RTL.Factory
  alias RTLWeb.Router.Helpers, as: Routes

  #
  # High-level
  #

  def login_as_new_user(conn, params \\ %{}) do
    user = Factory.insert_user(params)
    navigate_to Routes.auth_path(conn, :force_login, user.uuid)
    user
  end

  def login_as_superadmin(conn) do
    login_as_new_user(conn, %{email: "superadmin@example.com"})
  end

  #
  # DOM
  #

  # I always use css selectors, so I can simplify the helpers a bit
  def find_element(selector), do: find_element(:css, selector)

  def find_all_elements(selector), do: find_all_elements(:css, selector)

  def find_within_element(el, selector), do: find_within_element(el, :css, selector)

  def count_selector(selector) do
    length(find_all_elements(selector))
  end

  def assert_text(text) do
    wait_until(fn -> visible_page_text() =~ text end)
  end

  def refute_text(text) do
    wait_until(fn -> !(visible_page_text() =~ text) end)
  end

  def assert_html(text) do
    wait_until(fn -> page_source() =~ text end)
  end

  def assert_selector(sel, opts \\ %{}) do
    if opts[:count] do
      wait_until(fn -> count_selector(sel) == opts[:count] end)
    else
      wait_until(fn -> count_selector(sel) >= 1 end)
    end
  end

  def refute_selector(sel) do
    wait_until(fn -> count_selector(sel) == 0 end)
  end

  def wait_until(func, failures \\ 0) do
    cond do
      func.() == true -> nil

      failures < 10 ->
        Process.sleep(100)
        wait_until(func, failures + 1)

      true ->
        assert false, "The expected condition never became true.\n\n#{debug()}"

    end
  end

  def debug do
    "JS logs: \n<<<<\n#{fetch_log()}\n>>>>\n\nHTML source:\n<<<<\n#{page_source()}\n>>>>"
  end
end
