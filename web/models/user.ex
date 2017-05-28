defmodule Zb.User do
  use Zb.Web, :model

  alias Zb.Repo

  schema "users" do
    field :type, :string # indexed. [admin, faculty, student]
    field :email, :string # unique indexed
    field :password, :string, virtual: true
    field :password_hash, :string
    field :uuid, :string # indexed
    field :full_name, :string
    field :utc_offset, :integer
    field :min_votes_needed, :integer # can't be null
    field :last_signed_in_at, Timex.Ecto.DateTime # UTC
    has_many :interviews, Zb.Interview
    has_many :votes, Zb.Vote
    has_many :scheduled_tasks, Zb.ScheduledTask
    timestamps()
  end

  # === Changesets & validators ===

  def admin_changeset(struct, params \\ %{}) do
    struct
      # utc_offset and the timestamps are only updated via background processes
      |> cast(params, [:type, :email, :password, :full_name, :min_votes_needed, :last_signed_in_at])
      # password is NOT required (most users will never log in)
      |> validate_required([:type, :email, :full_name, :min_votes_needed])
      |> validate_inclusion(:type, ["admin", "faculty", "student"])
      |> unique_constraint(:email)
      |> put_password_hash_if_valid(struct)
      |> populate_uuid(struct)
  end

  defp put_password_hash_if_valid(changeset, struct) do
    cond do
      struct.password_hash != nil ->
        changeset
      changeset.valid? ->
        hashed = Comeonin.Bcrypt.hashpwsalt(changeset.changes.password)
        changeset |> put_change(:password_hash, hashed)
      true ->
        changeset
    end
  end

  defp populate_uuid(changeset, struct) do
    if struct.uuid do
      changeset
    else
      random_uuid = :crypto.strong_rand_bytes(8) |> Base.encode16
      put_change(changeset, :uuid, random_uuid)
    end
  end

  # === Computers ===

  def more_votes_needed?(user) do
    votes_completed = user |> assoc(:votes) |> Repo.count
    votes_completed < user.min_votes_needed
  end
end
