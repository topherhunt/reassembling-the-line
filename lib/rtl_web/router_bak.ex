# Docs: http://www.phoenixframework.org/docs/routing#section-the-endpoint-plugs
defmodule RTLWeb.Router do
  use RTLWeb, :router
  # See https://hexdocs.pm/rollbax/using-rollbax-in-plug-based-applications.html
  use Plug.ErrorHandler
  import RTLWeb.SessionPlugs, only: [
    load_current_user: 2,
    ensure_logged_in: 2
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

  scope "/", RTLWeb do
    pipe_through :browser

    get "/", HomeController, :index
    get "/test_error", HomeController, :test_error

    # Routes are organized by functional contexts.
    # Routes are NOT organized by user role, permissions, or scoped resources.
    # The contexts are:
    # - /auth (authentication & session)
    # - /manage (admin & superadmin features)
    # - /collect (tools for getting videos into the db)
    # - /process (tools for coder / admin to code & explore videos)
    # - /explore (tools for the end user to explore the coded results)

    scope "/auth" do
      # The Ueberauth login route redirects to Auth0's login page
      get "/login", AuthController, :login
      # Auth0 redirects back here after successful auth
      get "/auth0_callback", AuthController, :auth0_callback
      get "/logout", AuthController, :logout
      get "/login_from_uuid/:uuid", AuthController, :login_from_uuid
    end

    scope "/manage", as: :manage do
      resources "/users", Manage.UserController
      resources "/projects", Manage.ProjectController

      # Not scoped under /projects/:id so we can add a join from either direction
      resources "/project_admin_joins", Manage.ProjectAdminJoinController,
        only: [:create, :delete]

      scope "/projects/:project_id", as: :project do
        resources "/prompts", Manage.PromptController,
          only: [:show, :new, :create, :edit, :update, :delete]
      end
    end

    scope "/collect", as: :collect do
      scope "/projects/:project_uuid/" do
        scope "/prompts/:prompt_uuid" do
          # The admin-facing page explaining how you can import videos
          get "/instructions", Collect.InstructionsController, :index

          resources "/from_webcam", Collect.FromWebcamController, only: [:new, :create]
          get "/from_webcam/thank_you", Collect.FromWebcamController, :thank_you
        end
      end
    end

    scope "/process", as: :process do
      scope "/projects/:project_uuid" do
        resources "/videos", Process.VideoController, only: [:index]

        scope "/videos/:id", as: :video do
          resources "/codings", Process.CodingController,
            only: [:new, :create, :edit, :update]
        end
      end
    end

    scope "/explore", as: :explore do
      scope "/projects/:project_uuid" do
        get "/", ExploreController, :index
        get "/playlist", ExploreController, :playlist

        resources "/videos", VideoController, only: [:show]
      end
    end
  end

  defp handle_errors(conn, data) do
    RTLWeb.RollbarPlugs.handle_errors(conn, data)
  end
end
