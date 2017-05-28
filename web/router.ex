defmodule Zb.Router do
  # Docs: http://www.phoenixframework.org/docs/routing#section-the-endpoint-plugs

  use Zb.Web, :router
  import Zb.Auth, only: [load_current_user: 2, require_user: 2, require_admin: 2]

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
    plug :require_admin
  end

  scope "/", Zb do
    pipe_through :browser

    get "/", PageController, :index

    resources "/sessions", SessionController, only: [:new, :create, :delete]
    get "/sessions/login_from_uuid/:uuid", SessionController, :login_from_uuid

    resources "/interviews", InterviewController, only: [:edit, :update]
    get "/interviews/done", InterviewController, :done

    get "/votes/select_random", VoteController, :select_random
    get "/votes/done", VoteController, :done
    scope "/interviews/:interview_id", as: :interview do
      get "/votes/new", VoteController, :new
      post "/votes", VoteController, :create
    end

    resources "/help", HelpController, only: [:index, :create]

    get "/results", ResultController, :index

    scope "/admin", as: :admin do
      pipe_through :admin_area

      get "/", Admin.DashboardController, :index, as: :dashboard
      resources "/users", Admin.UserController, only: [:index, :show]
      get "/users/batch_new", Admin.UserController, :batch_new
      post "/users/batch_create", Admin.UserController, :batch_create
      resources "/questions", Admin.QuestionController, only: [:index]
      resources "/interviews", Admin.InterviewController, only: [:index, :show]
      resources "/tags", Admin.TagController, only: [:index]
      resources "/scheduled_tasks", Admin.ScheduledTaskController, only: [:index]
      resources "/contact_requests", Admin.ContactRequestController, only: [:index, :show]
    end
  end
end
