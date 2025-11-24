defmodule RealtimeQa.Rooms do
  import Ecto.Query
  alias RealtimeQa.{Repo, Room}

  def list_rooms do
    Repo.all(from r in Room, order_by: [desc: r.inserted_at])
  end

  def list_rooms_by_host(host_id) do
    Repo.all(
      from r in Room,
        where: r.host_id == ^host_id,
        order_by: [desc: r.inserted_at]
    )
  end

  def get_room!(id), do: Repo.get!(Room, id)

  def get_room_by_code(code) do
    Repo.get_by(Room, code: code)
    |> Repo.preload(:host)
  end

  def create_room(attrs, host_id) do
    code = generate_unique_code()

    attrs_with_host =
      attrs
      |> Map.put("host_id", host_id)
      |> Map.put("code", code)

    %Room{}
    |> Room.changeset(attrs_with_host)
    |> Repo.insert()
  end

  def generate_unique_code do
    code = do_generate_code()

    case get_room_by_code(code) do
      nil -> code
      _ -> generate_unique_code()
    end
  end

  defp do_generate_code do
    alphabet = "ABCDEFGHJKLMNPQRSTUVWXYZ23456789"
    for _ <- 1..6, into: "", do: <<Enum.random(String.to_charlist(alphabet))>>
  end

  def delete_room(%Room{} = room), do: Repo.delete(room)

  def is_host?(room, user_id) when is_integer(user_id) do
    room.host_id == user_id
  end

  def is_host?(_room, _user_id), do: false
end
