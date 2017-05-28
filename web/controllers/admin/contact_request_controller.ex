defmodule Zb.Admin.ContactRequestController do
  use Zb.Web, :controller
  alias Zb.ContactRequest

  def index(conn, _params) do
    render conn, "index.html", contact_requests: all_contact_requests()
  end

  def show(conn, %{"id" => id}) do
    message = Repo.get!(ContactRequest, id) |> Repo.preload(:user)
    render conn, "show.html", message: message
  end

  # Helpers

  defp all_contact_requests do
    ContactRequest
      |> order_by([r], desc: r.inserted_at)
      |> preload(:user)
      |> Repo.all
  end
end
