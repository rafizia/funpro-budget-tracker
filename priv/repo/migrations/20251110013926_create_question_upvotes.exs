defmodule RealtimeQa.Repo.Migrations.CreateQuestionUpvotes do
  use Ecto.Migration

  def change do
    create table(:question_upvotes) do
      add :user_fingerprint, :string, null: false
      add :question_id, references(:questions, on_delete: :delete_all), null: false

      timestamps(type: :utc_datetime)
    end

    # Index untuk performance
    create index(:question_upvotes, [:question_id])
    create index(:question_upvotes, [:user_fingerprint])

    # Unique constraint: 1 user hanya bisa upvote 1x per question
    create unique_index(:question_upvotes, [:question_id, :user_fingerprint])
  end
end
