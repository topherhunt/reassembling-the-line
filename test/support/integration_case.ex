defmodule Zb.IntegrationCase do
  use ExUnit.CaseTemplate

  using do
    quote do
      # use ExUnit.Case
      use Phoenix.ConnTest
      use Hound.Helpers # See https://github.com/HashNuke/hound for usage info

      import Ecto
      import Ecto.Changeset
      import Ecto.Query
      import Zb.Router.Helpers
      import Zb.ConnHelpers
      import Zb.Factory
      import Zb.ModelHelpers
      import Zb.EmailHelpers
      import Zb.ExtraHoundHelpers

      alias Zb.Repo

      @endpoint Zb.Endpoint
    end
  end

  setup tags do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(Zb.Repo)

    unless tags[:async] do
      Ecto.Adapters.SQL.Sandbox.mode(Zb.Repo, {:shared, self()})
    end

    Zb.ModelHelpers.empty_database

    {processes, _code} = System.cmd("ps", [])
    unless processes =~ "phantomjs --wd" do
      raise "Integration tests require PhantomJS webdriver. Run `phantomjs --wd` first."
    end

    {:ok, conn: Phoenix.ConnTest.build_conn()}
  end
end
