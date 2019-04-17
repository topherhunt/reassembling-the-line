# Docs: http://www.phoenixframework.org/docs/routing#section-the-endpoint-plugs
defmodule RTLWeb.Router do
  use RTLWeb, :router
  # See https://hexdocs.pm/rollbax/using-rollbax-in-plug-based-applications.html
  use Plug.ErrorHandler
  import RTLWeb.SessionPlugs, only: [load_current_user: 2, must_be_logged_in: 2]

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug Phoenix.LiveView.Flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug :load_current_user
  end

  pipeline :admin_area do
    plug :must_be_logged_in
  end

  scope "/", RTLWeb do
    pipe_through :browser

    get "/", HomeController, :index
    get "/test_error", HomeController, :test_error

    # The Ueberauth login route redirects to Auth0's login page
    get "/auth/login", AuthController, :login
    # Auth0 redirects back here after successful auth
    get "/auth/auth0_callback", AuthController, :auth0_callback
    get "/auth/logout", AuthController, :logout
    get "/auth/login_from_uuid/:uuid", AuthController, :login_from_uuid

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
      pipe_through :admin_area

      resources "/videos", Admin.VideoController, only: [:index]

      resources "/codings", Admin.CodingController, only: [:new, :create, :edit, :update]
    end
  end

  # Rollbax request error reporter
  # See https://hexdocs.pm/rollbax/using-rollbax-in-plug-based-applications.html
  # and file:///Users/topher/.hex/docs/hexpm/rollbax/0.10.0/Rollbax.html#report/5
  defp handle_errors(conn, %{kind: kind, reason: reason, stack: stacktrace}) do
    conn =
      conn
      |> Plug.Conn.fetch_cookies()
      |> Plug.Conn.fetch_query_params()

    params =
      case conn.params do
        %Plug.Conn.Unfetched{aspect: :params} -> "unfetched"
        other -> other
      end

    request_data = %{
      "request" => %{
        "cookies" => conn.req_cookies,
        "url" => "#{conn.scheme}://#{conn.host}:#{conn.port}#{conn.request_path}",
        "user_ip" => List.to_string(:inet.ntoa(conn.remote_ip)),
        "headers" => Enum.into(conn.req_headers, %{}),
        "method" => conn.method,
        "params" => params
      }
    }

    Rollbax.report(kind, reason, stacktrace, _custom_data = %{}, request_data)
  end
end
