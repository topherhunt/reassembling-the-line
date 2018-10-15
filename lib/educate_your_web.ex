defmodule EducateYourWeb do
  @moduledoc """
  The entrypoint for defining your web interface, such
  as controllers, views, channels and so on.

  This can be used in your application as:

      use EducateYourWeb, :controller
      use EducateYourWeb, :view

  The definitions below will be executed for every view,
  controller, etc, so keep them short and clean, focused
  on imports, uses and aliases.

  Do NOT define functions inside the quoted expressions
  below. Instead, define any helper function in modules
  and import those modules here.
  """

  def controller do
    quote do
      use Phoenix.Controller, namespace: EducateYourWeb
      import Plug.Conn
      import EducateYourWeb.Router.Helpers
      import EducateYourWeb.Gettext
      import EducateYourWeb.Auth, only: [
        must_be_logged_in: 2,
        must_not_be_logged_in: 2
      ]
      alias EducateYour.Helpers
    end
  end

  def view do
    quote do
      use Phoenix.View, root: "lib/educate_your_web/templates",
                        namespace: EducateYourWeb

      # Rendered HTML will automatically use EducateYour.LayoutView "app.html"
      # unless I specify another layout using Phoenix.Controller.put_layout/2.

      use Phoenix.HTML # All HTML functionality (forms, tags, etc)
      import Phoenix.Controller, only: [get_flash: 2, view_module: 1]
      import EducateYourWeb.Router.Helpers
      import EducateYourWeb.ErrorHelpers
      import EducateYourWeb.Gettext
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
    end
  end

  def channel do
    quote do
      use Phoenix.Channel
      import EducateYourWeb.Gettext
    end
  end

  # When used, dispatch to the appropriate controller/view/etc.
  defmacro __using__(which) when is_atom(which) do
    apply(__MODULE__, which, [])
  end
end
