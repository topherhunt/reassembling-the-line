# See http://www.phoenixframework.org/docs/sending-email for info on setting up
# email template layouts, plain text versions, etc.
# See also https://hexdocs.pm/bamboo/Bamboo.EmailPreviewPlug.html for easy previewing

defmodule Zb.Email do
  use Bamboo.Phoenix, view: Zb.EmailView

  alias Zb.Question

  def time_to_do_interview(user, interview) do
    new_email()
      |> to(user.email)
      |> from(System.get_env("SENDER_EMAIL"))
      |> subject("ZB Voices Project: Time to answer a quick question!")
      |> render("time_to_do_interview.html", user: user, interview: interview)
  end

  def time_to_vote(user) do
    new_email()
      |> to(user.email)
      |> from(System.get_env("SENDER_EMAIL"))
      |> subject("Follow-up on ZB Voices Project: Categorizing Submissions")
      |> render("time_to_vote.html", user: user, question: Question.voting_target())
  end

  def contact_request_received(request) do
    new_email()
      |> to(System.get_env("CONTACT_REQUEST_RECIPIENTS") |> String.split(","))
      |> from(System.get_env("SENDER_EMAIL"))
      |> put_header("Reply-To", request.email)
      |> subject("ZB Voices: New contact form message received from #{request.email}")
      |> render("contact_request_received.html", request: request)
  end
end
