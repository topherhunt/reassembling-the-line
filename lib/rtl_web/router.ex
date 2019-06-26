# Docs: http://www.phoenixframework.org/docs/routing#section-the-endpoint-plugs
defmodule RTLWeb.Router do
  use RTLWeb, :router
  # Rollbax error handler - see #handle_errors()
  use Plug.ErrorHandler
  import RTLWeb.SessionPlugs, only: [load_current_user: 2]
  import RTLWeb.SentryPlugs, only: [ensure_logged_in: 2]

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
    plug :ensure_logged_in
  end

  scope "/", RTLWeb do
    pipe_through :browser

    get "/", HomeController, :index
    get "/your_data", HomeController, :your_data
    get "/test_error", HomeController, :test_error

    #
    # Auth & session related routes
    #

    scope "/auth" do
      # The Ueberauth login route redirects to Auth0's login page
      get "/login", AuthController, :login
      # Auth0 redirects back here after successful auth
      get "/auth0_callback", AuthController, :auth0_callback
      get "/logout", AuthController, :logout
      get "/force_login/:uuid", AuthController, :force_login
    end

    #
    # Admin UI (manage structure, code videos, etc.)
    #

    scope "/manage", as: :manage do
      pipe_through :require_login

      resources "/users", Manage.UserController
      resources "/projects", Manage.ProjectController, param: "project_uuid"

      scope "/projects/:project_uuid" do
        get "/settings/:field/edit", Manage.ProjectSettingController, :edit
        patch "/settings/:field/", Manage.ProjectSettingController, :update
        patch "/settings/:field/clear", Manage.ProjectSettingController, :clear

        resources "/prompts", Manage.PromptController,
          except: [:index, :show],
          param: "prompt_uuid"

        resources "/videos", Manage.VideoController, only: [:index, :new, :create]
        get "/export_videos", Manage.VideoExportController, :new
        get "/import_videos", Manage.VideoImportController, :new
        post "/import_videos", Manage.VideoImportController, :create

        scope "/videos/:video_id", as: :video do
          resources "/codings", Manage.CodingController,
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
      scope "/share", as: :share do
        scope "/prompts/:prompt_uuid" do
          resources "/from_webcam", Share.FromWebcamController, only: [:new, :create]
          get "/from_webcam/thank_you", Share.FromWebcamController, :thank_you
        end
      end

      scope "/explore", as: :explore do
        get "/", Explore.ProjectController, :show

        get "/clips/", Explore.ClipController, :index
        get "/clips/playlist", Explore.ClipController, :playlist

        get "/videos/:id", Explore.VideoController, :show
      end
    end

    scope "/help" do
      get "/index", HelpController, :index
      get "/collecting_videos", HelpController, :collecting_videos
    end
  end

  pipeline :api do
    plug :accepts, ["json"]
    plug :fetch_session
    plug :load_current_user
  end

  scope "/api", RTLWeb do
    pipe_through :api

    post "/log", Api.LogController, :log
  end

  defp handle_errors(conn, data), do: RTLWeb.RollbarPlugs.handle_errors(conn, data)
end
