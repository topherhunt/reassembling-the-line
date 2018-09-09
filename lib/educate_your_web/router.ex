# Docs: http://www.phoenixframework.org/docs/routing#section-the-endpoint-plugs
defmodule EducateYourWeb.Router do
  use EducateYourWeb, :router
  import EducateYourWeb.Auth, only: [load_current_user: 2, must_be_logged_in: 2]

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug :load_current_user
  end

  pipeline :admin_area do
    plug :must_be_logged_in
  end

  scope "/", EducateYourWeb do
    pipe_through :browser

    get "/", HomeController, :index

    get "/sessions/logout", SessionController, :logout
    get "/sessions/login_from_uuid/:uuid", SessionController, :login_from_uuid

    get "/explore", ExploreController, :index
    get "/explore/playlist", ExploreController, :playlist

    resources "/videos", VideoController, only: [:show]

    scope "/admin", as: :admin do
      pipe_through :admin_area

      resources "/videos", Admin.VideoController, only: [:index]
      resources "/codings", Admin.CodingController, only: [:new, :create, :edit, :update]
    end
  end
end
