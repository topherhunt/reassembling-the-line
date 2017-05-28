defmodule EducateYour.Web do
  @moduledoc """
  A module that keeps using definitions for controllers,
  views and so on.

  This can be used in your application as:

      use EducateYour.Web, :controller
      use EducateYour.Web, :view

  The definitions below will be executed for every view,
  controller, etc, so keep them short and clean, focused
  on imports, uses and aliases.

  Do NOT define functions inside the quoted expressions
  below.
  """

  def model do
    quote do
      use Ecto.Schema
      use Timex.Ecto.Timestamps # Use Timex_Ecto integration on all models

      import Ecto
      import Ecto.Changeset
      import Ecto.Query
    end
  end

  def controller do
    quote do
      use Phoenix.Controller

      alias EducateYour.Repo
      import Ecto
      import Ecto.Query

      import EducateYour.Router.Helpers
      import EducateYour.Gettext
      import EducateYour.Auth, only: [require_user: 2]
    end
  end

  def view do
    quote do
      use Phoenix.View, root: "web/templates"

      # Rendered HTML will automatically use EducateYour.LayoutView "app.html"
      # unless I specify another layout using Phoenix.Controller.put_layout/2.

      use Phoenix.HTML # All HTML functionality (forms, tags, etc)
      import Phoenix.Controller, only: [get_csrf_token: 0, get_flash: 2, view_module: 1]
      import EducateYour.Router.Helpers
      import EducateYour.ErrorHelpers
      import EducateYour.Gettext
    end
  end

  def router do
    quote do
      use Phoenix.Router
    end
  end

  def channel do
    quote do
      use Phoenix.Channel

      alias EducateYour.Repo
      import Ecto
      import Ecto.Query
      import EducateYour.Gettext
    end
  end

  @doc """
  When used, dispatch to the appropriate controller/view/etc.
  """
  defmacro __using__(which) when is_atom(which) do
    apply(__MODULE__, which, [])
  end
end
