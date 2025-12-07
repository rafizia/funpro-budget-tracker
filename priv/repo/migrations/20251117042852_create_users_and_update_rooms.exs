defmodule RealtimeQa.Repo.Migrations.CreateUsersAndUpdateRooms do
  use Ecto.Migration

  def change do
    create table(:users) do
      add :email, :string, null: false
      add :name, :string, null: false
      add :google_id, :string, null: false
      add :avatar, :string

      timestamps(type: :utc_datetime)
    end

    create unique_index(:users, [:email])
    create unique_index(:users, [:google_id])

    alter table(:rooms) do
      add :host_id, references(:users, on_delete: :nilify_all)
    end

    create index(:rooms, [:host_id])
  end
end
