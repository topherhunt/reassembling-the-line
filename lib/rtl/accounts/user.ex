defmodule RTL.Accounts.User do
  use Ecto.Schema
  import RTLWeb.Gettext
  import Ecto.Changeset
  import Ecto.Query
  alias RTL.Accounts

  schema "users" do
    has_many :project_admin_joins, RTL.Projects.ProjectAdminJoin, foreign_key: :admin_id
    has_many :projects, through: [:project_admin_joins, :project]

    field :name, :string # may be nil (in edge cases)
    field :email, :string
    field :password_hash, :string
    field :password, :string, virtual: true
    field :password_confirmation, :string, virtual: true
    field :current_password, :string, virtual: true
    field :current_password_not_required, :boolean, virtual: true
    field :confirmed_at, :utc_datetime
    field :last_visit_date, :date
    field :session_token, :string

    timestamps()
  end

  #
  # Changesets
  #

  def changeset(struct, params, :owner) do
    struct
    |> cast(params, [:name, :email, :password, :password_confirmation, :current_password])
    |> disallow_email_change()
    |> validate_password_change()
    |> changeset(%{}, :admin) # Now run all standard validations too
  end

  # Admin can directly set/change a user's email or password with no confirmation step.
  def changeset(struct, params, :admin) do
    struct
    |> cast(params, [:name, :email, :password, :confirmed_at, :last_visit_date, :session_token])
    |> hash_password_if_present()
    |> require_password()
    |> downcase_field(:email)
    |> set_session_token()
    |> validate_required([:name, :email])
    |> unique_constraint(:email)
  end

  #
  # Helpers
  #

  # Users can't directly change their email address after registering.
  # Instead UserController#update sends a confirmation link to validate the new address.
  defp disallow_email_change(changeset) do
    is_user_new = changeset.data.id == nil
    is_changing_email = get_change(changeset, :email) != nil

    if is_changing_email && !is_user_new do
      add_error(changeset, :email, "can only be changed via a confirmation link")
    else
      changeset
    end
  end

  # Ensure the user is authorized to change their password (if they're trying to).
  defp validate_password_change(changeset) do
    user = changeset.data
    is_user_new = user.id == nil
    pw = get_change(changeset, :password)
    pw_conf = get_change(changeset, :password_confirmation)
    cur_pw = get_change(changeset, :current_password)
    cur_pw_required = !is_user_new && !get_field(changeset, :current_password_not_required)

    cond do
      pw == nil ->
        changeset

      # Does the password confirmation match?
      pw != pw_conf ->
        add_error(changeset, :password_confirmation, dgettext("errors", "doesn't match password"))

      # Does the current password match? (if it's required in this context)
      cur_pw_required && !Accounts.password_correct?(user, cur_pw) ->
        add_error(changeset, :current_password, dgettext("errors", "is incorrect"))

      true ->
        changeset
    end
  end

  defp hash_password_if_present(changeset) do
    if password = get_change(changeset, :password) do
      put_change(changeset, :password_hash, Argon2.hash_pwd_salt(password))
    else
      changeset
    end
  end

  # Must run after hashing the password.
  defp require_password(changeset) do
    if !get_field(changeset, :password_hash) do
      add_error(changeset, :password, dgettext("errors", "can't be blank"))
    else
      changeset
    end
  end

  defp downcase_field(changeset, field) do
    if value = get_change(changeset, field) do
      put_change(changeset, field, String.downcase(value))
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

  #
  # Filters
  #

  def filter(starting_query \\ __MODULE__, filters) do
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
