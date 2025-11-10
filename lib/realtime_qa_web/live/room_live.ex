defmodule RealtimeQaWeb.RoomLive do
  use RealtimeQaWeb, :live_view
  alias RealtimeQa.{Questions, Rooms}

  def render(assigns) do
    ~H"""
    <%= if @room do %>
      <div class="p-10">
        <div class="mb-8">
          <h1 class="text-4xl font-bold mb-2"><%= @room.title %></h1>
          <p class="text-gray-600 text-lg"><%= @room.description %></p>
          <p class="my-2">Room Code:</p>
          <p class="font-mono font-bold text-3xl"><%= @room.code %></p>
        </div>

        <div class="mb-8">
          <h2 class="text-2xl font-semibold mb-2">Ask a Question</h2>
          <form phx-submit="add_question">
            <input
              type="text"
              name="question"
              class="w-full bg-white rounded p-3"
              placeholder="Type your question..."
              required
            />
            <button class="bg-blue-700 text-lg font-medium text-white px-4 py-2 rounded mt-3">
              Submit Question
            </button>
          </form>
        </div>

        <div>
          <div class="flex items-center justify-between mb-6">
            <h2 class="text-2xl font-semibold">Questions</h2>
          </div>

          <div class="space-y-5">
            <%= for q <- @questions do %>
              <div class="bg-white rounded-lg shadow-sm p-7 hover:shadow-md transition-shadow">
                <div class="flex items-start gap-4">
                  <div class="flex-1 min-w-0">
                    <p class="text-xl text-gray-900"><%= q.content %></p>
                    <div class="mt-2 flex items-center gap-2 text-lg text-gray-500">
                      <span>Anonymous</span>
                    </div>
                  </div>
                  <div class="flex-none">
                    <button
                      phx-click="upvote"
                      phx-value-id={q.id}
                      class="flex flex-col items-center gap-1 group"
                    >
                    <svg xmlns="http://www.w3.org/2000/svg" width="25" height="25" viewBox="0 0 24 24" fill="none" stroke="#417505" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M14 9V5a3 3 0 0 0-3-3l-4 9v11h11.28a2 2 0 0 0 2-1.7l1.38-9a2 2 0 0 0-2-2.3zM7 22H4a2 2 0 0 1-2-2v-7a2 2 0 0 1 2-2h3"></path></svg>                      <span class="text-sm font-medium"><%= q.upvotes %></span>
                    </button>
                  </div>
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
              <label class="block text-xl font-medium mb-2">Enter Room Code</label>
              <input
                type="text"
                name="code"
                class="py-3 px-2 mt-1 block w-full rounded-md border-gray-300 shadow-sm focus:border-indigo-500 focus:ring-indigo-500"
                placeholder="Enter 6-character code"
                required
              />
            </div>
            <button type="submit" class="w-full bg-blue-700 text-white text-lg font-medium px-4 py-2 rounded hover:bg-blue-900">
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
