defmodule RTLWeb.HomeController do
  use RTLWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html", demo_coder: demo_coder())
  end

  defp demo_coder do
    RTL.Accounts.get_user_by(full_name: "Demo coder")
  end
end
