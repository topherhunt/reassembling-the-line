defmodule SignInAndOutTest do
  use Zb.IntegrationCase

  hound_session()

  test "user can sign in and out", _ do
    user = insert :user

    navigate_to "/"
    assert_logged_out()
    log_in_as(user)
    assert visible_page_text() =~ "Welcome back!"
    assert_logged_in()
    find_element(:css, ".sign-out-nav-link") |> click
    assert_logged_out()
  end

  # TODO
  # test "Session expiration works", _ do
    # Stub Timex.now to enable time travel; see https://github.com/jjh42/mock#example
    # TODO: session expires if no requests for 2 hours
    # TODO: session expiry countdown is reset on each request"
  # end

  defp log_in_as(user) do
    navigate_to "/sessions/new"
    find_element(:name, "session[email]")    |> fill_field(user.email)
    find_element(:name, "session[password]") |> fill_field(user.password)
    find_element(:css, ".sign-in-button")    |> click
  end

  defp assert_logged_in do
    assert_selector(:css, ".sign-out-nav-link")
    refute_selector(:css, ".sign-in-nav-link")
  end

  defp assert_logged_out do
    assert_selector(:css, ".sign-in-nav-link")
    refute_selector(:css, ".sign-out-nav-link")
  end
end
