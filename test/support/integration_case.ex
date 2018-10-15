defmodule RTLWeb.IntegrationCase do
  use ExUnit.CaseTemplate

  using do
    quote do
      use Phoenix.ConnTest
      use Hound.Helpers # See https://github.com/HashNuke/hound for usage info
      import RTL.DataHelpers
      import RTL.EmailHelpers
      import RTLWeb.Router.Helpers
      import RTLWeb.ExtraHoundHelpers
      alias RTL.Factory

      @endpoint RTLWeb.Endpoint
    end
  end

  setup tags do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(RTL.Repo)
    unless tags[:async] do
      Ecto.Adapters.SQL.Sandbox.mode(RTL.Repo, {:shared, self()})
    end
    RTL.DataHelpers.empty_database
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
