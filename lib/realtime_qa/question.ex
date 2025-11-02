defmodule RealtimeQa.Question do
  use Ecto.Schema
  import Ecto.Changeset

  schema "questions" do
    field :content, :string
    field :upvotes, :integer

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(question, attrs) do
    question
    |> cast(attrs, [:content, :upvotes])
    |> validate_required([:content, :upvotes])
  end
end
