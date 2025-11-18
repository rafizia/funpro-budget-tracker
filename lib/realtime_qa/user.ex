defmodule RealtimeQa.User do
  use Ecto.Schema
  import Ecto.Changeset

  schema "users" do
    field :email, :string
    field :name, :string
    field :google_id, :string
    field :avatar, :string

    has_many :rooms, RealtimeQa.Room, foreign_key: :host_id

    timestamps(type: :utc_datetime)
  end

  def changeset(user, attrs) do
    user
    |> cast(attrs, [:email, :name, :google_id, :avatar])
    |> validate_required([:email, :name, :google_id])
    |> validate_format(:email, ~r/^[^\s]+@[^\s]+$/, message: "must be a valid email")
    |> unique_constraint(:email)
    |> unique_constraint(:google_id)
  end
end
