# Docs: http://www.phoenixframework.org/docs/routing#section-the-endpoint-plugs
defmodule RTLWeb.Router do
  use RTLWeb, :router
  # Rollbax error handler - see #handle_errors()
  use Plug.ErrorHandler
  import RTLWeb.SessionPlugs, only: [load_current_user: 2]

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

    # get "/foo/:uuid", HomeController, :foo
    # resources "/foo", FooController

    # How routes are organized:
    # - All admin- or superadmin-only routes live under manage/
    # - Most routes are scoped by project (making it a required param)
    # - Some routes are similarly scoped by prompt
    # - User-facing routes live under /project/:slug/share/, /project/:slug/explore/, etc.

    scope "/auth" do
      # The Ueberauth login route redirects to Auth0's login page
      get "/login", AuthController, :login
      # Auth0 redirects back here after successful auth
      get "/auth0_callback", AuthController, :auth0_callback
      get "/logout", AuthController, :logout
      get "/login_from_uuid/:uuid", AuthController, :login_from_uuid
    end

    #
    # Admin UI (manage structure, code videos, etc.)
    #

    scope "/manage", as: :manage do
      resources "/users", Manage.UserController
      resources "/projects", Manage.ProjectController, param: "project_uuid"

      scope "/projects/:project_uuid" do
        resources "/prompts", Manage.PromptController, except: [:index], param: "prompt_uuid"

        resources "/videos", Manage.VideoController, only: [:index]
        scope "/videos/:video_id", as: :video do
          resources "/codings", Process.CodingController,
            only: [:new, :create, :edit, :update]
        end
      end

      # Not scoped under /projects/:id so we can add a join from either direction
      resources "/project_admin_joins", Manage.ProjectAdminJoinController,
        only: [:create, :delete]
    end

    #
    # Public-facing UI (share your story, explore results, etc.)
    #

    scope "/projects/:project_uuid" do
      get "/", ProjectController, :show

      scope "/share", as: :share do
        scope "/prompts/:prompt_uuid" do
          resources "/from_webcam", Collect.FromWebcamController, only: [:new, :create]
          get "/from_webcam/thank_you", Collect.FromWebcamController, :thank_you
        end
      end

      scope "/explore", as: :explore do
        get "/", ExploreController, :index
        get "/playlist", ExploreController, :playlist

        get "/videos/:id", Explore.VideoController, :show
      end
    end

    scope "/help" do
      get "/collecting_videos", HelpController, :collecting_videos
    end

  end

  defp handle_errors(conn, data), do: RTLWeb.RollbarPlugs.handle_errors(conn, data)
end
