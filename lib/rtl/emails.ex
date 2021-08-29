defmodule RTL.Emails do
  require Logger
  use Bamboo.Phoenix, view: RTLWeb.EmailsView
  import Bamboo.Email
  import RTLWeb.Gettext
  alias RTL.Accounts
  alias RTL.Accounts.User
  alias RTLWeb.Router.Helpers, as: Routes

  @endpoint RTLWeb.Endpoint

  def confirm_address(%User{} = user, email) do
    token = Accounts.create_token!({:confirm_email, user.id, email})
    url = Routes.auth_url(@endpoint, :confirm_email, token: token)
    if Mix.env == :dev, do: Logger.info "Email confirmation link sent to #{email}: #{url}"

    standard_email()
    |> to(email)
    |> subject("RTL: #{gettext "Please confirm your address"}")
    |> render("confirm_address.html", url: url)
  end

  def reset_password(%User{} = user) do
    token = Accounts.create_token!({:reset_password, user.id})
    url = Routes.auth_url(@endpoint, :reset_password, token: token)
    if Mix.env == :dev, do: Logger.info "PW reset link sent to #{user.email}: #{url}"

    standard_email()
    |> to(user.email)
    |> subject("RTL: #{gettext "Use this link to reset your password"}")
    |> render("reset_password.html", url: url)
  end

  #
  # Internal
  #

  defp standard_email do
    new_email()
    |> from({"Reassembling the Line", "noreply@reassemblingtheline.com"})
    |> put_html_layout({RTLWeb.LayoutView, "email.html"})
  end
end
