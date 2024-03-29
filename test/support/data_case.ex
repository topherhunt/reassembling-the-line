defmodule RTL.DataCase do
  @moduledoc """
  This module defines the test case to be used by
  model tests.

  You may define functions here to be used as helpers in
  your model tests. See `errors_on/2`'s definition as reference.

  Finally, if the test case interacts with the database,
  it cannot be async. For this reason, every test runs
  inside a transaction which is reset at the beginning
  of the test unless the test case is marked as async.
  """

  use ExUnit.CaseTemplate

  using do
    quote do
      import RTL.Factory
      import RTL.DataCase
      import RTL.DataHelpers
      import RTL.EmailHelpers
      import RTL.ValidationHelpers
      alias RTL.{Repo, Factory, Accounts}
      alias RTL.Accounts.User
      alias RTL.Helpers, as: H
    end
  end

  setup tags do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(RTL.Repo)

    unless tags[:async] do
      Ecto.Adapters.SQL.Sandbox.mode(RTL.Repo, {:shared, self()})
    end

    RTL.Factory.empty_database()

    :ok
  end
end
