defmodule RealtimeQaWeb.DashboardLive do
  use RealtimeQaWeb, :live_view
  alias RealtimeQa.Rooms

  def render(assigns) do
    ~H"""
    <div class="p-10">
      <h1 class="text-4xl font-bold mb-10">Q&A Dashboard</h1>

      <div class="mb-8">
        <h2 class="text-2xl font-semibold mb-4">Create New Room</h2>
        <form phx-submit="create_room">
          <div class="space-y-4">
            <div>
              <label class="block text-lg font-medium mb-2">Room Title</label>
              <input
                type="text"
                name="title"
                class="mt-1 block w-full rounded-md border-gray-300 shadow-sm p-3 focus:border-indigo-500 focus:ring-indigo-500"
                placeholder="My Q&A Session"
                required
              />
            </div>
            <div>
              <label class="block text-lg font-medium mb-2">Description (Optional)</label>
              <textarea
                name="description"
                rows="3"
                class="mt-1 block w-full rounded-md border-gray-300 shadow-sm p-3 focus:border-indigo-500 focus:ring-indigo-500"
                placeholder="What's this Q&A session about?"
              ></textarea>
            </div>
            <button type="submit" class="bg-blue-700 text-white text-lg font-medium px-4 py-2 rounded hover:bg-blue-900">
              Create Room
            </button>
          </div>
        </form>
      </div>

      <div>
        <h2 class="text-2xl font-semibold mb-4">Your Rooms</h2>
        <div class="grid gap-4 grid-cols-1 md:grid-cols-2 lg:grid-cols-3">
          <%= for room <- @rooms do %>
            <div class="bg-white rounded-lg shadow-sm p-7 hover:shadow-md transition-shadow">
              <h3 class="text-xl font-medium mb-2"><%= room.title %></h3>
              <p class="text-gray-500 mb-4"><%= room.description %></p>
              <div class="flex justify-between items-center">
                <div class="py-1 rounded text-black text-xl">
                  Code: <span class="font-mono font-bold"><%= room.code %></span>
                </div>
                <.link
                  navigate={~p"/room/#{room.code}"}
                  class="text-blue-500 hover:text-blue-700"
                >
                  View Room →
                </.link>
              </div>
            </div>
          <% end %>
        </div>
      </div>
    </div>
    """
  end

  def mount(_params, _session, socket) do
    {:ok, assign(socket, rooms: Rooms.list_rooms())}
  end

  def handle_event("create_room", %{"title" => title, "description" => description}, socket) do
    case Rooms.create_room(%{"title" => title, "description" => description}) do
      {:ok, _room} ->
        {:noreply,
         socket
         |> put_flash(:info, "Room created successfully!")
         |> assign(rooms: Rooms.list_rooms())}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply,
         socket
         |> put_flash(:error, "Error creating room: #{error_to_string(changeset)}")
         |> assign(rooms: Rooms.list_rooms())}
    end
  end

  defp error_to_string(changeset) do
    Ecto.Changeset.traverse_errors(changeset, fn {msg, opts} ->
      Enum.reduce(opts, msg, fn {key, value}, acc ->
        String.replace(acc, "%{#{key}}", to_string(value))
      end)
    end)
    |> Enum.map(fn {k, v} -> "#{k} #{v}" end)
    |> Enum.join(", ")
  end
end
