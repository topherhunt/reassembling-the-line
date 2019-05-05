defmodule RTL.Accounts.User do
  use Ecto.Schema
  import Ecto.Changeset
  import Ecto.Query

  schema "users" do
    field :full_name, :string
    field :email, :string
    field :uuid, :string
    field :auth0_uid, :string
    field :last_signed_in_at, Timex.Ecto.DateTime
    timestamps()

    has_many :project_admin_joins, RTL.Projects.ProjectAdminJoin, foreign_key: :admin_id
    has_many :projects, through: [:project_admin_joins, :project]
  end

  #
  # Changesets
  #

  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:full_name, :email, :auth0_uid, :last_signed_in_at])
    |> validate_required([:full_name, :email])
    |> populate_uuid()
    |> unique_constraint(:uuid)
    |> unique_constraint(:email)
    |> unique_constraint(:auth0_uid)
  end

  defp populate_uuid(changeset) do
    if get_field(changeset, :uuid),
      do: changeset,
      else: put_change(changeset, :uuid, RTL.Factory.random_uuid())
  end

  #
  # Filters
  #

  def filter(starting_query, filters) do
    Enum.reduce(filters, starting_query, fn {k, v}, query -> filter(query, k, v) end)
  end

  def filter(query, :id, id), do: where(query, [u], u.id == ^id)
  def filter(query, :uuid, uuid), do: where(query, [u], u.uuid == ^uuid)
  def filter(query, :email, email), do: where(query, [u], u.email == ^email)
  def filter(query, :auth0_uid, uid), do: where(query, [u], u.auth0_uid == ^uid)
  def filter(query, :full_name, name), do: where(query, [u], u.full_name == ^name)
  def filter(query, :preload, :projects), do: preload(query, :projects)
  def filter(query, :order, :newest), do: order_by(query, [u], desc: u.id)
  def filter(query, :order, :full_name), do: order_by(query, [u], asc: u.full_name)

  def filter(query, :admin_on_project, project) do
    where(
      query,
      [u],
      fragment(
        "EXISTS (SELECT * FROM project_admin_joins WHERE project_id = ? AND admin_id = ?)",
        ^project.id,
        u.id
      )
    )
  end

  def filter(query, :not_admin_on_project, project) do
    where(
      query,
      [u],
      fragment(
        "NOT EXISTS (SELECT * FROM project_admin_joins WHERE project_id = ? AND admin_id = ?)",
        ^project.id,
        u.id
      )
    )
  end
end
