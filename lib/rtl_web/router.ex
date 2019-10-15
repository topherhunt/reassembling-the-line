# Docs: http://www.phoenixframework.org/docs/routing#section-the-endpoint-plugs
defmodule RTLWeb.Router do
  use RTLWeb, :router
  # Rollbax error handler - see #handle_errors()
  use Plug.ErrorHandler
  import RTLWeb.AuthPlugs, only: [load_current_user: 2]
  import RTLWeb.SentryPlugs, only: [ensure_logged_in: 2]

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug Phoenix.LiveView.Flash
    # TODO: CSRF protection is DISABLED. Set up same-site cookies (lax).
    # plug :protect_from_forgery
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

    get "/auth/login", AuthController, :login
    post "/auth/login_submit", AuthController, :login_submit
    get "/auth/confirm", AuthController, :confirm
    get "/auth/log_out", AuthController, :log_out

    resources "/users", UserController, singleton: true, only: [:edit, :update]

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

        scope "/videos/:video_id" do
          get "/code", Manage.VideoController, :code
          post "/mark_coded", Manage.VideoController, :mark_coded
        end

        get "/export_videos", Manage.VideoExportController, :new
        get "/import_videos", Manage.VideoImportController, :new
        post "/import_videos", Manage.VideoImportController, :create
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
      get "/coding_page", HelpController, :coding_page
    end

    # In dev, preview all "sent" emails at localhost:4000/sent_emails
    if Mix.env == :dev do
      forward "/sent_emails", Bamboo.SentEmailViewerPlug
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

  pipeline :graphql do
    plug :accepts, ["json"]
    plug :fetch_session
    plug :load_current_user
    plug :set_absinthe_context
  end

  scope "/graphql" do
    pipe_through :graphql

    forward "/graphiql", Absinthe.Plug.GraphiQL,
      schema: RTLWeb.Graphql.Schema,
      json_codec: Jason

    forward "/", Absinthe.Plug,
      schema: RTLWeb.Graphql.Schema,
      json_codec: Jason
  end

  defp handle_errors(conn, data), do: RTLWeb.RollbarPlugs.handle_errors(conn, data)

  defp set_absinthe_context(conn, _) do
    Absinthe.Plug.put_options(conn, context: %{current_user: conn.assigns.current_user})
  end
end
