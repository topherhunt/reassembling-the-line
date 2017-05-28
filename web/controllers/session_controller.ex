defmodule Zb.SessionController do
  use Zb.Web, :controller

  alias Zb.{Auth, User, TaskComputer}

  def new(conn, _) do
    render conn, "new.html"
  end

  def create(conn, %{"session" => %{"email" => email, "password" => pw}}) do
    case Auth.try_login(conn, email, pw) do
      {:ok, conn} ->
        conn
          |> put_flash(:info, "Welcome back!")
          |> redirect(to: page_path(conn, :index))
      {:error, _reason, conn} ->
        conn
          |> put_flash(:error, "That email or password is incorrect.")
          |> render("new.html")
    end
  end

  def login_from_uuid(conn, %{"uuid" => uuid} = params) do
    user = Repo.get_by!(User, uuid: uuid)
    redirect_path = params["redirect_to"] || redirect_url_for(user, conn)
    conn
      |> Auth.login!(user)
      |> redirect(to: redirect_path)
  end

  def delete(conn, _params) do
    conn
      |> Auth.logout!
      |> redirect(to: page_path(conn, :index))
  end

  # Helpers

  defp redirect_url_for(user, conn) do
    if user.type == "admin" do
      admin_dashboard_path(conn, :index)
    else
      # Redirect me to my next task regardless of whether it's due or not.
      case TaskComputer.next_available_action(user) do
        {:do_interview, interview} ->
          interview_path(conn, :edit, interview)
        {:vote} ->
          vote_path(conn, :select_random)
        {:nothing} ->
          # If no pending tasks, redirect to the "You're done with your interview" page.
          # I think that's not ideal, but least likely to confuse users.
          interview_path(conn, :done)
      end
    end
  end
end
