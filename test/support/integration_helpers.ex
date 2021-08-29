defmodule RTLWeb.IntegrationHelpers do
  use ExUnit.CaseTemplate
  # See https://github.com/HashNuke/hound for docs
  use Hound.Helpers
  alias RTL.Factory
  alias RTLWeb.Router.Helpers, as: Routes

  #
  # High-level
  #

  def login(user) do
    navigate_to Routes.auth_url(RTLWeb.Endpoint, :login)
    find_element("#user_email") |> fill_field(user.email)
    find_element("#user_password") |> fill_field("password")
    find_element(~s(button[type="submit"])) |> click()
    assert_content "Welcome back!"
    assert_content "Log out"
  end

  def login_as_new_user(params \\ %{}) do
    user = Factory.insert_user(params)
    login(user)
    user
  end

  def login_as_superadmin do
    login_as_new_user(%{email: "superadmin@example.com"})
  end

  #
  # DOM
  #

  # Select an option from a dropdown (<select> element).
  # See https://stackoverflow.com/a/49861811/1729692
  def select_option(select_el, value) do
    find_within_element(select_el, ~s(option[value="#{value}"])) |> click()
  end

  # I always use css selectors, so I can simplify the helpers a bit
  def find_element(selector), do: find_element(:css, selector)

  def find_all_elements(selector), do: find_all_elements(:css, selector)

  def find_within_element(el, selector), do: find_within_element(el, :css, selector)

  def count_selector(selector) do
    length(find_all_elements(selector))
  end

  # Content can be plain text, HTML, or a regex.
  def assert_content(content) do
    wait_until(fn -> page_source() =~ content end)
  end

  def refute_content(content) do
    wait_until(fn -> !(page_source() =~ content) end)
  end

  # TODO: Migrate usages to assert_content
  def assert_text(text) do
    wait_until(fn -> visible_page_text() =~ text end)
  end

  # TODO: Migrate usages to refute_content
  def refute_text(text) do
    wait_until(fn -> !(visible_page_text() =~ text) end)
  end

  # TODO: Migrate usages to assert_content
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
    screenshot_path = take_screenshot()
    filepath = RTLWeb.ConnHelpers.write_response_body_to_file(page_source())
    "JS logs: #{fetch_log()}\n\nView the HTML source: #{filepath}\n\nView screenshot: #{screenshot_path}"
  end
end
