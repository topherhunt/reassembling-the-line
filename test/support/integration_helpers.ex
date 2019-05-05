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

  def assert_text(text) do
    assert visible_page_text() =~ text
  end

  def assert_selector(selector, opts \\ %{}) do
    actual = length(find_all_elements(selector))

    if opts[:count] do
      assert actual == opts[:count],
        "Expected to find selector \"#{selector}\" exactly #{opts[:count]} times, but found it #{actual} times."
    else
      assert actual >= 1,
        "Expected to find selector \"#{selector}\" 1+ times, but found none."
    end
  end

  def refute_selector(selector) do
    actual = length(find_all_elements(selector))
    assert actual == 0, "Expected NOT to find selector \"#{selector}\", but found #{actual}."
  end

  #
  # Debugging
  #

  def print_page_source() do
    IO.puts("<<<<<<< Page source: >>>>>>")
    IO.puts(page_source())
    IO.puts("<<<<<<<<<<<<<<>>>>>>>>>>>>>")
  end
end
