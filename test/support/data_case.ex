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
      import RTL.DataCase
      import RTL.DataHelpers
      import RTL.EmailHelpers
      import RTL.ValidationHelpers
      alias RTL.Factory
      # Minimize my reliance on this
      alias RTL.Repo
    end
  end

  setup tags do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(RTL.Repo)

    unless tags[:async] do
      Ecto.Adapters.SQL.Sandbox.mode(RTL.Repo, {:shared, self()})
    end

    RTL.DataHelpers.empty_database()

    :ok
  end
end
