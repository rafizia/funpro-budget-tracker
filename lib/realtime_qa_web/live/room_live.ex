defmodule RealtimeQaWeb.RoomLive do
  use RealtimeQaWeb, :live_view
  alias RealtimeQa.{Questions, Rooms}

  def render(assigns) do
    ~H"""
    <%= if @room do %>
      <div class="p-10">
        <div class="mb-8">
          <h1 class="text-4xl font-bold mb-2"><%= @room.title %></h1>
          <p class="text-gray-600"><%= @room.description %></p>
          <p class="mt-2">Room Code: <span class="font-mono font-bold"><%= @room.code %></span></p>
        </div>

        <div class="mb-8">
          <h2 class="text-2xl font-semibold mb-2">Ask a Question</h2>
          <form phx-submit="add_question">
            <input
              type="text"
              name="question"
              class="w-full border rounded p-2"
              placeholder="Type your question..."
              required
            />
            <button class="bg-blue-500 text-white px-4 py-2 rounded mt-2">
              Submit Question
            </button>
          </form>
        </div>

        <div>
          <h2 class="text-2xl font-semibold mb-4">Questions</h2>
          <div class="space-y-4">
            <%= for q <- @questions do %>
              <div class="flex items-center justify-between border-b py-4">
                <span class="flex-1 mr-4"><%= q.content %></span>
                <div class="flex items-center space-x-2">
                  <button
                    phx-click="upvote"
                    phx-value-id={q.id}
                    class="px-3 py-1 rounded bg-green-100 hover:bg-green-200 text-gray-600"
                  >
                    👍 <%= q.upvotes %>
                  </button>
                </div>
              </div>
            <% end %>
          </div>
        </div>
      </div>
    <% else %>
      <div class="p-10">
        <h1 class="text-4xl font-bold mb-8">Join a Room</h1>
        <div class="max-w-md">
          <form phx-submit="join_room" class="space-y-4">
            <div>
              <label class="block text-lg font-medium">Enter Room Code</label>
              <input
                type="text"
                name="code"
                class="py-3 px-2 mt-1 block w-full rounded-md border-gray-300 shadow-sm focus:border-indigo-500 focus:ring-indigo-500"
                placeholder="Enter 6-character code"
                required
              />
            </div>
            <button type="submit" class="w-full bg-blue-500 text-white px-4 py-2 rounded hover:bg-blue-600">
              Join Room
            </button>
          </form>
        </div>
      </div>
    <% end %>
    """
  end

  def mount(_params, _session, socket) do
    {:ok, assign(socket, room: nil, questions: [])}
  end

  def handle_params(%{"code" => code}, _uri, socket) do
    case Rooms.get_room_by_code(code) do
      nil ->
        {:noreply,
         socket
         |> put_flash(:error, "Room not found")
         |> push_navigate(to: ~p"/")}

      room ->
        {:noreply,
         socket
         |> assign(room: room, questions: Questions.list_questions(room.id))}
    end
  end

  def handle_params(_params, _uri, socket) do
    {:noreply, assign(socket, room: nil, questions: [])}
  end

  def handle_event("join_room", %{"code" => code}, socket) do
    {:noreply, push_patch(socket, to: ~p"/room/#{code}")}
  end

  def handle_event("add_question", %{"question" => content}, socket) do
    room = socket.assigns.room

    case Questions.create_question(%{
           "content" => content,
           "room_id" => room.id
         }) do
      {:ok, _question} ->
        {:noreply,
         socket
         |> assign(questions: Questions.list_questions(room.id))}

      {:error, _changeset} ->
        {:noreply,
         socket
         |> put_flash(:error, "Error creating question")}
    end
  end

  def handle_event("upvote", %{"id" => id}, socket) do
    Questions.upvote_question(id)
    room = socket.assigns.room
    {:noreply, assign(socket, questions: Questions.list_questions(room.id))}
  end
end
