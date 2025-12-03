defmodule RealtimeQaWeb.DashboardLive do
  use RealtimeQaWeb, :live_view
  alias RealtimeQa.Rooms

  def render(assigns) do
    ~H"""
    <div class="min-h-screen bg-gray-50">
      <!-- Header -->
      <div class="bg-white shadow-sm border-b border-gray-200">
        <div class="container mx-auto px-6 py-4">
          <div class="flex justify-between items-center">
            <div class="flex items-center gap-4">
              <h1 class="text-3xl font-bold text-gray-900">Dashboard</h1>
            </div>
            <div class="flex items-center gap-4">
              <div class="hidden md:block">
                <p class="text-sm font-medium text-gray-900">{@current_user.name}</p>
                <p class="text-xs text-gray-500">{@current_user.email}</p>
              </div>
              <.link navigate={~p"/"} class="px-4 py-2 text-gray-700 bg-gray-200 rounded-lg hover:bg-gray-300 transition">
                Home
              </.link>
              <!-- Fixed Logout Button -->
              <form action={~p"/auth/logout"} method="post">
                <input type="hidden" name="_csrf_token" value={get_csrf_token()} />
                <button
                  type="submit"
                  class="px-4 py-2 text-white bg-red-600 rounded-lg hover:bg-red-700 transition"
                >
                  Logout
                </button>
              </form>
            </div>
          </div>
        </div>
      </div>

      <div class="container mx-auto px-6 py-10">
        <!-- Create Room Section -->
        <div class="bg-white rounded-lg shadow-md p-8 mb-10">
          <h2 class="text-2xl font-bold mb-6 text-gray-900">Create New Room</h2>
          <form phx-submit="create_room" class="space-y-5">
            <div>
              <label class="block text-sm font-medium text-gray-700 mb-2">Room Title</label>
              <input
                type="text"
                name="title"
                class="w-full px-4 py-3 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500"
                placeholder="e.g., Weekly Team Meeting"
                required
              />
            </div>
            <div>
              <label class="block text-sm font-medium text-gray-700 mb-2">Description (Optional)</label>
              <textarea
                name="description"
                rows="3"
                class="w-full px-4 py-3 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500"
                placeholder="What's this room about?"
              ></textarea>
            </div>
            <button
              type="submit"
              class="bg-blue-600 text-white text-lg font-medium px-6 py-3 rounded-lg hover:bg-blue-700 transition"
            >
              Create Room
            </button>
          </form>
        </div>

        <!-- Rooms List -->
        <div class="bg-white rounded-lg shadow-md p-8">
          <h2 class="text-2xl font-bold mb-6 text-gray-900">Your Rooms ({length(@rooms)})</h2>
          <%= if Enum.empty?(@rooms) do %>
            <div class="text-center py-12">
              <svg class="w-16 h-16 text-gray-400 mx-auto mb-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M20 13V6a2 2 0 00-2-2H6a2 2 0 00-2 2v7m16 0v5a2 2 0 01-2 2H6a2 2 0 01-2-2v-5m16 0h-2.586a1 1 0 00-.707.293l-2.414 2.414a1 1 0 01-.707.293h-3.172a1 1 0 01-.707-.293l-2.414-2.414A1 1 0 006.586 13H4"/>
              </svg>
              <p class="text-gray-500 text-lg mb-2">No rooms yet</p>
              <p class="text-gray-400 text-sm">Create your first room above to get started!</p>
            </div>
          <% else %>
            <div class="grid gap-6 grid-cols-1 md:grid-cols-2 lg:grid-cols-3">
              <%= for room <- @rooms do %>
                <div class="border border-gray-200 rounded-lg p-6 hover:shadow-lg transition-shadow bg-gradient-to-br from-white to-gray-50">
                  <h3 class="text-xl font-semibold text-gray-900 mb-2">{room.title}</h3>
                  <p class="text-gray-600 mb-4 min-h-[3rem] line-clamp-2">{room.description || "No description"}</p>

                  <div class="bg-blue-50 border border-blue-200 rounded-lg p-3 mb-4">
                    <p class="text-xs text-gray-600 mb-1">Room Code</p>
                    <p class="font-mono font-bold text-2xl text-blue-600">{room.code}</p>
                  </div>

                  <div class="flex gap-2">
                    <.link
                      navigate={~p"/room/#{room.code}"}
                      class="flex-1 text-center bg-blue-600 text-white px-4 py-2 rounded-lg hover:bg-blue-700 transition"
                    >
                      Open Room
                    </.link>
                    <a
                      href={~p"/export/room/#{room.id}"}
                      class="px-4 py-2 bg-green-600 text-white rounded-lg hover:bg-green-700 transition flex items-center justify-center"
                      title="Export to CSV"
                    >
                      <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor" class="w-6 h-6">
                        <path stroke-linecap="round" stroke-linejoin="round" d="M3 16.5v2.25A2.25 2.25 0 0 0 5.25 21h13.5A2.25 2.25 0 0 0 21 18.75V16.5M16.5 12 12 16.5m0 0L7.5 12m4.5 4.5V3" />
                      </svg>
                    </a>
                    <button
                      phx-click="delete_room"
                      phx-value-id={room.id}
                      data-confirm="Are you sure you want to delete this room? All questions will be lost."
                      class="px-4 py-2 bg-red-600 text-white rounded-lg hover:bg-red-700 transition"
                      title="Delete Room"
                    >
                      <svg class="w-6 h-6 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 7l-.867 12.142A2 2 0 0116.138 21H7.862a2 2 0 01-1.995-1.858L5 7m5 4v6m4-6v6m1-10V4a1 1 0 00-1-1h-4a1 1 0 00-1 1v3M4 7h16"/>
                      </svg>
                    </button>
                  </div>

                  <p class="text-xs text-gray-400 mt-3">
                    Created {Calendar.strftime(room.inserted_at, "%b %d, %Y")}
                  </p>
                </div>
              <% end %>
            </div>
          <% end %>
        </div>
      </div>
    </div>
    """
  end

  def mount(_params, _session, socket) do
    rooms = Rooms.list_rooms_by_host(socket.assigns.current_user.id)
    {:ok, assign(socket, rooms: rooms)}
  end

  def handle_event("create_room", params, socket) do
    title = Map.get(params, "title", "")
    description = Map.get(params, "description", "")

    case Rooms.create_room(
      %{"title" => title, "description" => description},
      socket.assigns.current_user.id
    ) do
      {:ok, room} ->
        {:noreply,
         socket
         |> put_flash(:info, "Room created successfully!")
         |> push_navigate(to: ~p"/room/#{room.code}")}

      {:error, %Ecto.Changeset{} = changeset} ->
        errors = error_to_string(changeset)
        {:noreply, put_flash(socket, :error, "Error creating room: #{errors}")}
    end
  end

  def handle_event("delete_room", %{"id" => id}, socket) do
    room = Rooms.get_room!(id)

    # Verify ownership
    if room.host_id == socket.assigns.current_user.id do
      {:ok, _} = Rooms.delete_room(room)
      rooms = Rooms.list_rooms_by_host(socket.assigns.current_user.id)

      {:noreply,
       socket
       |> assign(rooms: rooms)
       |> put_flash(:info, "Room deleted successfully")}
    else
      {:noreply, put_flash(socket, :error, "Unauthorized")}
    end
  end

  defp get_csrf_token do
    Phoenix.Controller.get_csrf_token()
  end

  defp error_to_string(changeset) do
    Ecto.Changeset.traverse_errors(changeset, fn {msg, opts} ->
      Enum.reduce(opts, msg, fn {key, value}, acc ->
        String.replace(acc, "%{#{key}}", to_string(value))
      end)
    end)
    |> Enum.map(fn {k, v} -> "#{k}: #{inspect(v)}" end)
    |> Enum.join(", ")
  end
end
