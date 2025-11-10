defmodule RealtimeQa.Rooms do
  import Ecto.Query, warn: false
  alias RealtimeQa.Repo
  alias RealtimeQa.Room

  def list_rooms do
    Repo.all(from r in Room, order_by: [desc: r.inserted_at])
  end

  def get_room_by_code(code) when is_binary(code) do
    Repo.one(from r in Room, where: r.code == ^code)
  end

  def create_room(attrs \\ %{}) do
    # Generate a unique 6-character code
    code = generate_unique_code()

    %Room{}
    |> Room.changeset(Map.put(attrs, "code", code))
    |> Repo.insert()
  end

  defp generate_unique_code do
    code = random_string(6)

    if get_room_by_code(code) do
      generate_unique_code()
    else
      code
    end
  end

  defp random_string(length) do
    allowed = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
    allowed_length = String.length(allowed)

    1..length
    |> Enum.map(fn _ ->
      :rand.uniform(allowed_length) - 1
      |> then(&String.at(allowed, &1))
    end)
    |> Enum.join("")
  end
end
