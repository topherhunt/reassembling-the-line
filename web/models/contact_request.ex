defmodule Zb.ContactRequest do
  use Zb.Web, :model

  schema "contact_requests" do
    belongs_to :user, Zb.User
    field :email, :string
    field :subject, :string
    field :body, :string
    timestamps()
  end

  def changeset(struct, params \\ %{}) do
    struct
      |> cast(params, [:email, :subject, :body])
      |> validate_required([:email, :subject, :body])
      |> assoc_constraint(:user)
  end
end
