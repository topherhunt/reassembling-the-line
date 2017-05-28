defmodule Zb.HelpControllerTest do
  use Zb.ConnCase
  alias Zb.{ContactRequest, Email}

  test "#index renders", %{conn: conn} do
    conn = get(conn, help_path(conn, :index))
    assert html_response(conn, 200) =~ "Contact us"
  end

  test "#create logs the request and sends the email", %{conn: conn} do
    assert Repo.count(ContactRequest) == 0
    conn = post(conn, help_path(conn, :create), contact_request: %{email: "elmer.fudd@gmail.com", subject: "Request subject", body: "Test body"})
    assert redirected_to(conn) == help_path(conn, :index)
    assert Repo.count(ContactRequest) == 1
    assert delivered_email? Email.contact_request_received(Repo.one(ContactRequest))
  end

  test "#create with invalid params makes no changes and renders errors", %{conn: conn} do
    assert Repo.count(ContactRequest) == 0
    conn = post(conn, help_path(conn, :create), contact_request: %{email: "elmer.fudd@gmail.com", subject: "Test subject", body: ""})
    assert html_response(conn, 200) =~ "Your message couldn't be submitted. Please check for errors below."
    assert Repo.count(ContactRequest) == 0
  end
end
