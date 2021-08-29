defmodule RTL.EmailHelpers do
  use ExUnit.CaseTemplate

  def count_emails_sent, do: length(Bamboo.SentEmail.all())

  def assert_email_sent([to: to, subject: subject]) do
    to = [to] |> List.flatten() |> Enum.sort()

    matches = Bamboo.SentEmail.all()
    matches = Enum.filter(matches, & &1.to |> Keyword.values() |> Enum.sort() == to)
    matches = Enum.filter(matches, & &1.subject =~ subject)

    if length(matches) == 0 do
      all = Enum.map(Bamboo.SentEmail.all(), fn email ->
        to = email.to |> Keyword.values() |> Enum.sort()
        "  * [to: #{inspect(to)}, subject: \"#{email.subject}\"]"
      end)

      raise "No matching email found.\n\nSearched for:\n    [to: #{to}, subject: \"#{subject}\"]\n\nAll emails sent:\n#{Enum.join(all, "\n")}"
    end
  end

  #
  # Old code, probably no longer needed
  #

  # NOTE: This only returns emails sent by / to this Process -- meaning our
  # integration tests don't have access to the emails sent server-side.
  # Switch to using Bamboo.LocalAdapter instead, which catches messages and
  # stores them in an array, exactly as I want.
  # def all_delivered_emails do
  #   {:messages, messages} = Process.info(self(), :messages)

  #   messages
  #   |> Enum.filter(fn message ->
  #     case message do
  #       {:delivered_email, _email} -> true
  #       _other_format -> nil
  #     end
  #   end)
  #   |> Enum.map(fn {:delivered_email, email} -> email end)
  # end

  # def delivered_email?(expected_email) do
  #   # Normalization trick copied from Bamboo.Test
  #   expected_email =
  #     expected_email
  #     |> Bamboo.Mailer.normalize_addresses()
  #     |> Bamboo.TestAdapter.clean_assigns()

  #   expected_email in all_delivered_emails()
  # end

  # def emails_delivered_to(user) do
  #   all_delivered_emails() |> Enum.filter(&email_addressed_to?(&1, user.email))
  # end

  # def email_addressed_to?(email, target_address) do
  #   email.to |> Enum.any?(fn {_, address} -> address == target_address end)
  # end

  # def print_all_delivered_emails do
  #   IO.puts("All sent emails:\n=========================")
  #   all_delivered_emails() |> Enum.map(fn email -> IO.inspect(email) end)
  #   IO.puts("=========================")
  # end
end
