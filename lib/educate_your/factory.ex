defmodule EducateYour.Factory do
  use ExMachina.Ecto, repo: EducateYour.Repo

  # Returns an unpersisted struct with all foreign key _id fields populated.
  # Useful when testing validations: we need a valid, unpersisted struct that
  # contains all the fields accepted by the changeset.
  def build_with_assocs(factory, opts \\ %{}) do
    build(factory, params_with_assocs(factory, opts))
  end

  # TODO: Write factories in here

  # Helpers

  defp random_hex do
    :crypto.strong_rand_bytes(4) |> Base.encode16
  end
end
