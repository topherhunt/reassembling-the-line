defmodule Zb.HelpController do
  use Zb.Web, :controller
  alias Zb.{ContactRequest, Email, Mailer}

  def index(conn, _params) do
    changeset = ContactRequest.changeset(%ContactRequest{})
    render conn, "index.html", changeset: changeset
  end

  def create(conn, %{"contact_request" => contact_params}) do
    changeset = new_contact_request(conn) |> ContactRequest.changeset(contact_params)
    case Repo.insert(changeset) do
      {:ok, contact} ->
        Email.contact_request_received(contact) |> Mailer.deliver_now
        conn
          |> put_flash(:info, "Thanks! We've received your request and will reply soon.")
          |> redirect(to: help_path(conn, :index))
      {:error, changeset} ->
        render conn, "index.html", changeset: changeset
    end
  end

  # Helpers

  defp new_contact_request(conn) do
    if user = conn.assigns.current_user do
      %ContactRequest{user_id: user.id}
    else
      %ContactRequest{}
    end
  end
end
