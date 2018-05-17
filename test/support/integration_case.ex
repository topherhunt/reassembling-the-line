defmodule EducateYour.IntegrationCase do
  use ExUnit.CaseTemplate

  using do
    quote do
      use Phoenix.ConnTest
      use Hound.Helpers # See https://github.com/HashNuke/hound for usage info

      import Ecto
      import Ecto.Changeset
      import Ecto.Query
      import EducateYour.Router.Helpers
      import EducateYour.Factory
      import EducateYour.ModelHelpers
      import EducateYour.EmailHelpers
      import EducateYour.ExtraHoundHelpers

      alias EducateYour.Repo

      @endpoint EducateYour.Endpoint
    end
  end

  setup tags do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(EducateYour.Repo)
    unless tags[:async] do
      Ecto.Adapters.SQL.Sandbox.mode(EducateYour.Repo, {:shared, self()})
    end
    EducateYour.ModelHelpers.empty_database
    ensure_phantomjs_running()
    {:ok, conn: Phoenix.ConnTest.build_conn()}
  end

  def ensure_phantomjs_running do
    {processes, _code} = System.cmd("ps", [])
    unless processes =~ "phantomjs --wd" do
      raise "Integration tests require PhantomJS. Run `phantomjs --wd` first."
    end
  end
end
