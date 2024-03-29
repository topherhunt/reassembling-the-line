defmodule RTLWeb.ConnCase do
  @moduledoc """
  This module defines the test case to be used by
  tests that require setting up a connection.

  Such tests rely on `Phoenix.ConnTest` and also
  import other functionality to make it easier
  to build and query models.

  Finally, if the test case interacts with the database,
  it cannot be async. For this reason, every test runs
  inside a transaction which is reset at the beginning
  of the test unless the test case is marked as async.
  """

  use ExUnit.CaseTemplate

  using do
    quote do
      # Import conveniences for testing with connections
      use Phoenix.ConnTest
      import RTL.Factory
      import RTL.DataHelpers
      import RTL.EmailHelpers
      import RTLWeb.ConnHelpers
      alias RTLWeb.Router.Helpers, as: Routes
      alias RTL.{Repo, Factory, Accounts}
      alias RTL.Accounts.User
      alias RTL.Helpers, as: H

      # The default endpoint for testing
      @endpoint RTLWeb.Endpoint
    end
  end

  setup tags do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(RTL.Repo)

    unless tags[:async] do
      Ecto.Adapters.SQL.Sandbox.mode(RTL.Repo, {:shared, self()})
    end

    RTL.Factory.empty_database()
    System.put_env("SUPERADMIN_EMAILS", "superadmin@example.com")
    {:ok, conn: Phoenix.ConnTest.build_conn()}
  end
end
