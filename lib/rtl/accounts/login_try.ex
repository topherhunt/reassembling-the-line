# Tracks login attempts for a specific email address so we can block brute-force attacks.
defmodule RTL.Accounts.LoginTry do
  use Ecto.Schema
  import Ecto.Changeset

  schema "login_tries" do
    field :email, :string
    timestamps()
  end

  def admin_changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:email])
    |> validate_required([:email])
    |> downcase_email()
  end

  #
  # Internal
  #

  defp downcase_email(changeset) do
    if email = get_change(changeset, :email) do
      changeset |> change(%{email: String.downcase(email)})
    else
      changeset
    end
  end
end
