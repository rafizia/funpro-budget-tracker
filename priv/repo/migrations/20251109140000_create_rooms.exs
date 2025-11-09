defmodule RealtimeQa.Repo.Migrations.CreateRooms do
  use Ecto.Migration

  def change do
    create table(:rooms) do
      add :title, :string, null: false
      add :code, :string, null: false
      add :description, :string

      timestamps(type: :utc_datetime)
    end

    create unique_index(:rooms, [:code])

    alter table(:questions) do
      add :room_id, references(:rooms, on_delete: :delete_all), null: false
    end

    create index(:questions, [:room_id])
  end
end
