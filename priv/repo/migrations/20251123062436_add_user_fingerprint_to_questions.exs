defmodule RealtimeQa.Repo.Migrations.AddUserFingerprintToQuestions do
  use Ecto.Migration

  def change do
    alter table(:questions) do
      add :user_fingerprint, :string
    end
  end
end
