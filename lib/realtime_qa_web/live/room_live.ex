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
                    class={upvote_button_class(q.id, @upvoted_questions)}
                    disabled={is_upvoted?(q.id, @upvoted_questions)}
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

  # lifecycle callbacks
  def mount(_params, session, socket) do
    fingerprint = session["user_fingerprint"] || generate_fallback_fingerprint(socket)

    {:ok,
    socket
    |> assign(room: nil, questions: [], upvoted_questions: MapSet.new())
    |> assign(user_fingerprint: fingerprint)}
  end

  defp generate_fallback_fingerprint(socket) do
    peer_data = get_connect_info(socket, :peer_data)
    user_agent = get_connect_info(socket, :user_agent) || "unknown"
    ip = extract_ip(peer_data)

    :crypto.hash(:sha256, "#{ip}-#{user_agent}-#{:erlang.unique_integer()}")
    |> Base.encode16()
    |> String.slice(0..31)
  end

  def handle_params(%{"code" => code}, _uri, socket) do
    case Rooms.get_room_by_code(code) do
      nil ->
        {:noreply,
         socket
         |> put_flash(:error, "Room not found")
         |> push_navigate(to: ~p"/")}

      room ->
        # Load questions dan upvoted status
        questions = Questions.list_questions(room.id)
        upvoted = Questions.get_upvoted_question_ids(room.id, socket.assigns.user_fingerprint)

        {:noreply,
         socket
         |> assign(room: room, questions: questions, upvoted_questions: upvoted)}
    end
  end

  def handle_params(_params, _uri, socket) do
    {:noreply, assign(socket, room: nil, questions: [])}
  end

  # event handler
  def handle_event("join_room", %{"code" => code}, socket) do
    {:noreply, push_patch(socket, to: ~p"/room/#{code}")}
  end

  def handle_event("add_question", %{"question" => content}, socket) do
    room = socket.assigns.room

    case Questions.create_question(%{"content" => content, "room_id" => room.id}) do
      {:ok, _question} ->
        {:noreply, socket |> assign(questions: Questions.list_questions(room.id))}

      {:error, _changeset} ->
        {:noreply, socket |> put_flash(:error, "Error creating question")}
    end
  end

  def handle_event("upvote", %{"id" => id}, socket) do
    question_id = String.to_integer(id)
    fingerprint = socket.assigns.user_fingerprint
    upvoted = socket.assigns.upvoted_questions

    if is_upvoted?(question_id, upvoted) do
      {:noreply, socket}
    else
      case Questions.add_upvote(question_id, fingerprint) do
        {:ok, _question} ->
          new_upvoted = MapSet.put(upvoted, question_id)
          new_questions = Questions.list_questions(socket.assigns.room.id)

          {:noreply,
           socket
           |> assign(questions: new_questions, upvoted_questions: new_upvoted)}

        {:error, _reason} ->
          {:noreply, socket |> put_flash(:error, "Failed to upvote")}
      end
    end
  end

  # helper function
  defp extract_ip(%{address: address}) do
    address
    |> Tuple.to_list()
    |> Enum.join(".")
  end
  defp extract_ip(_), do: "unknown"

  defp is_upvoted?(question_id, upvoted_set) do
    MapSet.member?(upvoted_set, question_id)
  end

  defp upvote_button_class(question_id, upvoted_set) do
    if is_upvoted?(question_id, upvoted_set) do
      "px-3 py-1 rounded bg-green-500 text-white cursor-not-allowed opacity-70"
    else
      "px-3 py-1 rounded bg-green-100 hover:bg-green-200 text-gray-600"
    end
  end
end
