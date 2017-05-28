# These helpers are heavily inspired from Bamboo.Test, but rewritten such that
# checking for an email doesn't delete it from the message queue.
defmodule EducateYour.EmailHelpers do
  # NOTE: This only returns emails sent by / to this Process -- meaning our
  # integration tests don't have access to the emails sent server-side.
  # Switch to using Bamboo.LocalAdapter instead, which catches messages and
  # stores them in an array, exactly as I want.
  def all_delivered_emails do
    {:messages, messages} = Process.info(self(), :messages)
    messages
      |> Enum.filter(fn(message) ->
        case message do
          {:delivered_email, _email} -> true
          _other_format -> nil
        end
      end)
      |> Enum.map(fn({:delivered_email, email}) -> email end)
  end

  def delivered_email?(expected_email) do
    # Normalization trick copied from Bamboo.Test
    expected_email = expected_email
      |> Bamboo.Mailer.normalize_addresses
      |> Bamboo.TestAdapter.clean_assigns
    expected_email in all_delivered_emails()
  end

  def emails_delivered_to(%EducateYour.User{} = user) do
    all_delivered_emails()
      |> Enum.filter(fn(email) ->
        email.to |> Enum.any?(fn({_, to_address}) -> to_address == user.email end)
      end)
  end

  def print_all_delivered_emails do
    IO.puts "All sent emails:\n========================="
    all_delivered_emails() |> Enum.map(fn(email) -> IO.inspect email end)
    IO.puts "========================="
  end
end
