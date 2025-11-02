defmodule RealtimeQa.Repo.Migrations.CreateQuestions do
  use Ecto.Migration

  def change do
    create table(:questions) do
      add :content, :string
      add :upvotes, :integer

      timestamps(type: :utc_datetime)
    end
  end
end
