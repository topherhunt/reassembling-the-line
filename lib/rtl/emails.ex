defmodule RTL.Emails do
  use Bamboo.Phoenix, view: RTLWeb.EmailsView
  import Bamboo.Email
  import RTLWeb.Gettext
  alias RTLWeb.Router.Helpers, as: Routes
  require Logger

  def confirm_address(email) do
    token = RTL.Accounts.get_login_token(email)
    url = Routes.auth_url(RTLWeb.Endpoint, :confirm, token: token)

    if Mix.env == :dev, do: Logger.info "Login link for #{email}: #{url}"

    new_email()
    |> to(email)
    |> from("noreply@reassemblingtheline.com")
    |> subject("[RTL] #{gettext("Your login link")}")
    |> put_html_layout({RTLWeb.LayoutView, "email.html"})
    |> render("confirm_address.html", url: url)
  end
end
