defmodule RealtimeQa.Question do
  use Ecto.Schema
  import Ecto.Changeset

  schema "questions" do
    field :content, :string
    field :user_fingerprint, :string
    field :upvotes, :integer, default: 0

    belongs_to :room, RealtimeQa.Room
    has_many :question_upvotes, RealtimeQa.QuestionUpvote

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(question, attrs) do
    question
    |> cast(attrs, [:content, :room_id, :user_fingerprint])
    |> validate_required([:content, :room_id, :user_fingerprint])
    |> foreign_key_constraint(:room_id)
  end
end
