defmodule RTLWeb do
  @moduledoc """
  The entrypoint for defining your web interface, such
  as controllers, views, channels and so on.

  This can be used in your application as:

      use RTLWeb, :controller
      use RTLWeb, :view

  The definitions below will be executed for every view,
  controller, etc, so keep them short and clean, focused
  on imports, uses and aliases.

  Do NOT define functions inside the quoted expressions
  below. Instead, define any helper function in modules
  and import those modules here.
  """

  def controller do
    quote do
      use Phoenix.Controller, namespace: RTLWeb, log: false
      # Make sure we get live_render from P.LV.Controller, not Phoenix.LiveView
      import Phoenix.LiveView.Controller, only: [live_render: 3]
      import Plug.Conn
      import RTLWeb.Gettext

      import RTLWeb.SentryPlugs,
        only: [
          load_project: 2,
          load_prompt: 2,
          ensure_logged_in: 2,
          ensure_not_logged_in: 2,
          ensure_superadmin: 2,
          ensure_can_manage_project: 2
        ]

      alias RTLWeb.Router.Helpers, as: Routes
      alias RTL.Helpers, as: H
    end
  end

  def view do
    quote do
      use Phoenix.View, root: "lib/rtl_web/templates", namespace: RTLWeb
      use Phoenix.HTML
      import Phoenix.Controller, only: [get_flash: 2, view_module: 1]
      import Phoenix.LiveView, only: [live_render: 2, live_render: 3]
      import RTL.Sentry, only: [is_superadmin?: 1, can_manage_project?: 2]
      import RTLWeb.Gettext
      import RTLWeb.{ErrorHelpers, DateHelpers, IconHelpers, RouteHelpers, TextHelpers}

      alias RTLWeb.Router.Helpers, as: Routes

      # Rendered HTML will automatically use RTL.LayoutView "app.html"
      # unless I specify another layout using Phoenix.Controller.put_layout/2.
    end
  end

  # TODO: Figure out how to avoid the reraise/3 deprecation warning:
  # https://github.com/elixir-plug/plug/issues/706
  # https://github.com/elixir-plug/plug/commit/7e7164576fe181a3aaf6afd629199edf45a0a591#diff-ed8c15512ce84b85449e74f5a48d5bbbR21
  def router do
    quote do
      use Phoenix.Router
      import Plug.Conn
      import Phoenix.Controller
      import Phoenix.LiveView.Router
    end
  end

  def channel do
    quote do
      use Phoenix.Channel
      import RTLWeb.Gettext
    end
  end

  # When used, dispatch to the appropriate controller/view/etc.
  defmacro __using__(which) when is_atom(which) do
    apply(__MODULE__, which, [])
  end
end
