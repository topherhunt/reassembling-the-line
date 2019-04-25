# Docs: http://www.phoenixframework.org/docs/routing#section-the-endpoint-plugs
defmodule RTLWeb.Router do
  use RTLWeb, :router
  # See https://hexdocs.pm/rollbax/using-rollbax-in-plug-based-applications.html
  use Plug.ErrorHandler
  import RTLWeb.SessionPlugs, only: [
    load_current_user: 2,
    must_be_logged_in: 2
  ]

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug Phoenix.LiveView.Flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug :load_current_user
  end

  pipeline :require_login do
    plug :must_be_logged_in
  end

  scope "/", RTLWeb do
    pipe_through :browser

    get "/", HomeController, :index
    get "/test_error", HomeController, :test_error

    scope "/auth" do
      # The Ueberauth login route redirects to Auth0's login page
      get "/login", AuthController, :login
      # Auth0 redirects back here after successful auth
      get "/auth0_callback", AuthController, :auth0_callback
      get "/logout", AuthController, :logout
      get "/login_from_uuid/:uuid", AuthController, :login_from_uuid
    end

    get "/explore", ExploreController, :index
    get "/explore/playlist", ExploreController, :playlist

    resources "/videos", VideoController, only: [:show]

    scope "/collect", as: :collect do
      get "/hub", Collect.HubController, :index

      resources "/webcam_recordings", Collect.WebcamRecordingController, only: [:new, :create]
      get "/webcam_recordings/thank_you", Collect.WebcamRecordingController, :thank_you
    end

    # TODO: I shouldn't organize my controllers based on shared attributes /
    # privilege level. Rather, group controllers based on functional area of
    # the app, e.g. collect, code, explore, manage.
    scope "/admin", as: :admin do
      pipe_through :require_login

      resources "/videos", Admin.VideoController, only: [:index]
      resources "/codings", Admin.CodingController, only: [:new, :create, :edit, :update]
    end

    scope "/manage", as: :manage do
      pipe_through :require_login

      resources "/users", Manage.UserController
      resources "/projects", Manage.ProjectController
      resources "/project_admin_joins", Manage.ProjectAdminJoinController, only: [:create, :delete]
    end
  end

  defp handle_errors(conn, data) do
    RTLWeb.RollbarPlugs.handle_errors(conn, data)
  end
end
