defmodule RealtimeQa.Repo.Migrations.AddIsPrioritizedToQuestions do
  use Ecto.Migration

  def change do
    alter table(:questions) do
      add :is_prioritized, :boolean, default: false, null: false
    end

    create index(:questions, [:room_id, :is_prioritized])
  end
end
