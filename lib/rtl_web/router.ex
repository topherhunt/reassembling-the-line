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
    # Note: CSRF protection is DISABLED, so we rely on same-site cookies.
    # plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug :load_current_user
  end

  pipeline :admin do
    plug :ensure_logged_in
  end

  pipeline :api do
    plug :accepts, ["json"]
    plug :fetch_session
    plug :load_current_user
  end

  pipeline :graphql do
    plug :accepts, ["json"]
    plug :fetch_session
    plug :load_current_user
    plug :set_absinthe_context
  end

  scope "/", RTLWeb do
    pipe_through :browser

    get "/", HomeController, :index
    get "/your_data", HomeController, :your_data
    get "/test_error", HomeController, :test_error

    get "/help", HelpController, :index
    get "/help/collecting_videos", HelpController, :collecting_videos
    get "/help/coding_page", HelpController, :coding_page

    get "/auth/login", AuthController, :login
    post "/auth/login_submit", AuthController, :login_submit
    get "/auth/confirm", AuthController, :confirm
    get "/auth/log_out", AuthController, :log_out

    resources "/users", UserController, singleton: true, only: [:edit, :update]

    #
    # Admin- and superadmin-facing routes
    #

    scope "/admin", as: :admin do
      pipe_through :admin

      resources "/users", Admin.UserController
      resources "/projects", Admin.ProjectController, param: "project_uuid"

      resources "/project_admin_joins", Admin.ProjectAdminJoinController,
        only: [:create, :delete]

      scope "/projects/:project_uuid" do
        resources "/custom_blocks", Admin.CustomBlockController,
          only: [:index, :edit, :update, :delete], param: "label"
        get "/custom_blocks/export", Admin.CustomBlockController, :export
        get "/custom_blocks/import", Admin.CustomBlockController, :import
        post "/custom_blocks/import_submit", Admin.CustomBlockController, :import_submit

        resources "/prompts", Admin.PromptController,
          except: [:index, :show], param: "prompt_uuid"

        resources "/videos", Admin.VideoController, only: [:index, :new, :create]
        get "/videos/:video_id/code", Admin.VideoController, :code
        post "/videos/:video_id/mark_coded", Admin.VideoController, :mark_coded

        get "/export_videos", Admin.VideoExportController, :new
        get "/import_videos", Admin.VideoImportController, :new
        post "/import_videos", Admin.VideoImportController, :create
      end
    end

    #
    # Public-facing project-related routes
    #

    scope "/projects/:project_uuid" do
      get "/", ProjectController, :show

      resources "/prompts/:prompt_uuid/videos", VideoController, only: [:new, :create]
      get "/videos/thank_you", VideoController, :thank_you
      get "/videos/:id", VideoController, :show
      # Legacy URL for webcam recording page
      get "/share/prompts/:prompt_uuid/from_webcam/new", VideoController, :new

      get "/results/", ResultsController, :index
      get "/results/playlist", ResultsController, :playlist
    end

    # In dev, preview all "sent" emails at localhost:4000/sent_emails
    if Mix.env == :dev do
      forward "/sent_emails", Bamboo.SentEmailViewerPlug
    end
  end

  scope "/api", RTLWeb do
    pipe_through :api

    post "/log", Api.LogController, :log
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
