defmodule RealtimeQa.Question do
  use Ecto.Schema
  import Ecto.Changeset

  schema "questions" do
    field :content, :string
    field :upvotes, :integer, default: 0

    belongs_to :room, RealtimeQa.Room

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(question, attrs) do
    question
    |> cast(attrs, [:content, :room_id])
    |> validate_required([:content, :room_id])
    |> foreign_key_constraint(:room_id)
  end
end
