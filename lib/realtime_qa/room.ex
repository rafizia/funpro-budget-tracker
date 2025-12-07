defmodule RealtimeQa.Room do
  use Ecto.Schema
  import Ecto.Changeset

  schema "rooms" do
    field :title, :string
    field :code, :string
    field :description, :string

    belongs_to :host, RealtimeQa.User, foreign_key: :host_id
    has_many :questions, RealtimeQa.Question

    timestamps(type: :utc_datetime)
  end

  def changeset(room, attrs) do
    room
    |> cast(attrs, [:title, :code, :description, :host_id])
    |> validate_required([:title, :code])
    |> validate_length(:code, is: 6)
    |> unique_constraint(:code)
    |> foreign_key_constraint(:host_id)
  end
end
