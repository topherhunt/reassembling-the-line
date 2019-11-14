defmodule RTL.Accounts.User do
  use Ecto.Schema
  import Ecto.Changeset
  import Ecto.Query

  schema "users" do
    field :name, :string # may be nil (in edge cases)
    field :email, :string
    field :session_token, :string
    field :last_visit_date, :date
    field :require_name, :boolean, virtual: true

    timestamps()

    has_many :project_admin_joins, RTL.Projects.ProjectAdminJoin, foreign_key: :admin_id
    has_many :projects, through: [:project_admin_joins, :project]
  end

  #
  # Changesets
  #

  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:name, :email, :session_token, :last_visit_date, :require_name])
    |> downcase_email()
    |> set_session_token()
    |> validate_required([:email, :session_token])
    |> maybe_require_name()
    |> unique_constraint(:email)
  end

  defp downcase_email(changeset) do
    email = get_field(changeset, :email) || ""
    downcased = String.downcase(email)

    if email != downcased do
      put_change(changeset, :email, downcased)
    else
      changeset
    end
  end

  defp set_session_token(changeset) do
    if get_field(changeset, :session_token) == nil do
      put_change(changeset, :session_token, Nanoid.generate(20))
    else
      changeset
    end
  end

  # To make registration seamless, we only require user's name on the "My profile" page.
  # The user will be guided here after registration, or on subsequent login if they
  # haven't already set their name.
  defp maybe_require_name(changeset) do
    if get_field(changeset, :require_name) do
      changeset |> validate_required([:name])
    else
      changeset
    end
  end

  #
  # Filters
  #

  def filter(starting_query, filters) do
    Enum.reduce(filters, starting_query, fn {k, v}, query -> filter(query, k, v) end)
  end

  def filter(query, :id, id), do: where(query, [u], u.id == ^id)
  def filter(query, :email, e), do: where(query, [u], u.email == ^String.downcase(e))
  def filter(query, :session_token, st), do: where(query, [u], u.session_token == ^st)
  def filter(query, :preload, :projects), do: preload(query, :projects)
  def filter(query, :order, :newest), do: order_by(query, [u], desc: u.id)
  def filter(query, :order, :name), do: order_by(query, [u], asc: u.name)

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
