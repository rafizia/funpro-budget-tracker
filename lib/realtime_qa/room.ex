defmodule RealtimeQa.Room do
  use Ecto.Schema
  import Ecto.Changeset

  schema "rooms" do
    field :title, :string
    field :code, :string
    field :description, :string

    has_many :questions, RealtimeQa.Question

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(room, attrs) do
    room
    |> cast(attrs, [:title, :code, :description])
    |> validate_required([:title, :code])
    |> validate_length(:code, min: 6, max: 6)
    |> unique_constraint(:code)
  end
end
