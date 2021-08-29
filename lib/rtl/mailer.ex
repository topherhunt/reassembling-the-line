defmodule RTL.Mailer do
  require Logger
  use Bamboo.Mailer, otp_app: :rtl
  import Bamboo.Email
  alias RTL.Helpers, as: H

  def send(email) do
    try do
      email = modify_subject_if_staging(email)
      deliver_now(email)
      log :info, "email sent (#{describe_email(email)})"
      {:ok}
    # SMTP failures may raise ErlangErrors which need to be caught rather than rescued (?)
    catch e ->
      log :warn, "Error sending email #{describe_email(email)}: #{inspect(e)}"
      {:error, e}
    end
  end

  #
  # Internal
  #

  defp modify_subject_if_staging(email) do
    if H.env("STAGING") do
      email |> subject("[STAGING] #{email.subject}")
    else
      email
    end
  end

  defp describe_email(email) do
    module = "#{email.private.view_module}" |> String.split(".") |> List.last()
    template = email.private.view_template |> String.split(".") |> List.first()
    to = inspect(email.to)
    "to=#{to}, template=\"#{module}.#{template}\", subject=\"#{email.subject}\""
  end

  defp log(level, msg), do: Logger.log(level, "RTL.Mailer: #{msg}")
end
