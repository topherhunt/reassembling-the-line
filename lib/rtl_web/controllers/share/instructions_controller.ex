defmodule RTLWeb.Collect.InstructionsController do
  use RTLWeb, :controller

  plug :load_project
  plug :load_prompt
  plug :ensure_logged_in
  plug :must_be_project_admin_or_superadmin

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
