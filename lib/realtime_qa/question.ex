defmodule RealtimeQa.Question do
  use Ecto.Schema
  import Ecto.Changeset

  schema "questions" do
    field :content, :string
    field :upvotes, :integer, default: 0

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(question, attrs) do
    question
    |> cast(attrs, [:content])
    |> validate_required([:content])
  end
end
