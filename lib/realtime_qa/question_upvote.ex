defmodule RealtimeQa.QuestionUpvote do
  use Ecto.Schema
  import Ecto.Changeset

  schema "question_upvotes" do
    field :user_fingerprint, :string
    belongs_to :question, RealtimeQa.Question

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(upvote, attrs) do
    upvote
    |> cast(attrs, [:question_id, :user_fingerprint])
    |> validate_required([:question_id, :user_fingerprint])
    |> foreign_key_constraint(:question_id)
    |> unique_constraint([:question_id, :user_fingerprint],
      name: :question_upvotes_question_id_user_fingerprint_index
    )
  end
end
