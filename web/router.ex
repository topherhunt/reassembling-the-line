defmodule EducateYour.Router do
  # Docs: http://www.phoenixframework.org/docs/routing#section-the-endpoint-plugs

  use EducateYour.Web, :router
  import EducateYour.Auth, only: [load_current_user: 2, require_user: 2]

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug :load_current_user
  end

  pipeline :admin_area do
    plug :require_user
  end

  scope "/", EducateYour do
    pipe_through :browser

    get "/", HomeController, :index

    get "/sessions/logout", SessionController, :logout
    get "/sessions/login_from_uuid/:uuid", SessionController, :login_from_uuid

    # TODO: Fill in other routes
  end
end
