defmodule RTLWeb.ConnHelpers do
  use ExUnit.CaseTemplate
  use Phoenix.ConnTest
  import RTL.Factory
  alias RTLWeb.Router.Helpers, as: Routes

  @endpoint RTLWeb.Endpoint

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

  def assert_logged_in(conn, user) do
    conn = get(conn, Routes.home_path(conn, :index))
    assert_content(conn, "Log out")
    assert_content(conn, user.name)
    refute_content(conn, "Log in")
  end

  def assert_logged_out(conn) do
    conn = get(conn, Routes.home_path(conn, :index))
    assert_content(conn, "Log in")
    refute_content(conn, "Log out")
  end

  def flash_messages(conn) do
    conn.private.phoenix_flash |> Map.values() |> Enum.join(" ")
  end

  # Content can be plain text, HTML, or a regex.
  def assert_content(conn, content) do
    cleaned_body = conn.resp_body |> String.replace(~r/\s\s+/, " ")

    unless cleaned_body =~ content do
      filepath = write_response_body_to_file(conn.resp_body)
      raise "Expected the response html to include #{inspect(content)}, but it didn't. \nView the full response at: #{filepath}"
    end
  end

  def refute_content(conn, content) do
    cleaned_body = conn.resp_body |> String.replace(~r/\s\s+/, " ")

    if cleaned_body =~ content do
      filepath = write_response_body_to_file(conn.resp_body)
      raise "Expected the response html to NOT include #{inspect(content)}, but it did. \nView the full response at: #{filepath}"
    end
  end

  def assert_selector(conn, selector, opts \\ []) do
    {:ok, doc} = Floki.parse_document(conn.resp_body)
    matches = Floki.find(doc, selector)

    # Filter matches to those that match the :html pattern (if provided)
    matches =
      if opts[:html] do
        Enum.filter(matches, & Floki.raw_html(&1) =~ opts[:html])
      else
        matches
      end

    if opts[:count] do
      unless length(matches) == opts[:count] do
        filepath = write_response_body_to_file(conn.resp_body)
        raise "Expected to find selector '#{selector}' #{opts[:count]} times, but found it #{length(matches)} times. \nView the full html at: #{filepath}"
      end
    else
      unless length(matches) >= 1 do
        filepath = write_response_body_to_file(conn.resp_body)
        raise "Expected to find selector '#{selector}' one or more times, but found it 0 times. \nView the full html at: #{filepath}"
      end
    end
  end

  def refute_selector(conn, selector) do
    assert_selector(conn, selector, count: 0)
  end

  def write_response_body_to_file(source_html) do
    System.cmd("mkdir", ["-p", "./tmp/test_failures"])
    filename = "#{Date.utc_today}_#{Nanoid.generate(6)}.html"
    filepath = "./tmp/test_failures/#{filename}"
    File.write!(filepath, source_html)
    filepath
  end
end
