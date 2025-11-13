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
          <p class="font-mono font-bold text-4xl"><%= @room.code %></p>
        </div>

        <div class="mb-8">
          <h2 class="text-2xl font-semibold mb-4">Ask a Question</h2>
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
          <div class="flex items-center justify-between mb-4">
            <h2 class="text-2xl font-semibold">Questions</h2>
          </div>
          <div class="space-y-5">
            <%= for q <- @questions do %>
              <div class="bg-white rounded-lg shadow-sm p-7 hover:shadow-md transition-shadow">
                <div class="flex items-start gap-4">
                  <div class="flex-1 min-w-0">
                    <p class="text-xl text-gray-900"><%= q.content %></p>
                    <div class="mt-2 flex items-center gap-2 text-sm text-gray-500">
                      <span>Anonymous</span>
                    </div>
                  </div>
                  <div class="flex-none">
                    <button
                      phx-click="upvote"
                      phx-value-id={q.id}
                      class={upvote_button_class(q.id, @upvoted_questions)}
                      disabled={is_upvoted?(q.id, @upvoted_questions)}
                      >
                      <%= if is_upvoted?(q.id, @upvoted_questions) do %>
                        <svg class="w-[30px] h-[30px] text-gray-800 dark:text-white" aria-hidden="true" xmlns="http://www.w3.org/2000/svg" width="24" height="24" fill="currentColor" viewBox="0 0 24 24">
                          <path fill-rule="evenodd" fill="green" d="M15.03 9.684h3.965c.322 0 .64.08.925.232.286.153.532.374.717.645a2.109 2.109 0 0 1 .242 1.883l-2.36 7.201c-.288.814-.48 1.355-1.884 1.355-2.072 0-4.276-.677-6.157-1.256-.472-.145-.924-.284-1.348-.404h-.115V9.478a25.485 25.485 0 0 0 4.238-5.514 1.8 1.8 0 0 1 .901-.83 1.74 1.74 0 0 1 1.21-.048c.396.13.736.397.96.757.225.36.32.788.269 1.211l-1.562 4.63ZM4.177 10H7v8a2 2 0 1 1-4 0v-6.823C3 10.527 3.527 10 4.176 10Z" clip-rule="evenodd"/>
                        </svg>
                      <% else %>
                        <svg class="w-[30px] h-[30px] text-gray-800 dark:text-white" aria-hidden="true" xmlns="http://www.w3.org/2000/svg" width="24" height="24" fill="none" viewBox="0 0 24 24">
                          <path stroke="currentColor" stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M7 11c.889-.086 1.416-.543 2.156-1.057a22.323 22.323 0 0 0 3.958-5.084 1.6 1.6 0 0 1 .582-.628 1.549 1.549 0 0 1 1.466-.087c.205.095.388.233.537.406a1.64 1.64 0 0 1 .384 1.279l-1.388 4.114M7 11H4v6.5A1.5 1.5 0 0 0 5.5 19v0A1.5 1.5 0 0 0 7 17.5V11Zm6.5-1h4.915c.286 0 .372.014.626.15.254.135.472.332.637.572a1.874 1.874 0 0 1 .215 1.673l-2.098 6.4C17.538 19.52 17.368 20 16.12 20c-2.303 0-4.79-.943-6.67-1.475"/>
                        </svg>
                      <% end %>
                      <span class="text-sm font-medium"><%= q.upvotes %></span>
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
      "px-3 py-1 rounded text-gray-600 cursor-not-allowed"
    else
      "px-3 py-1 rounded text-gray-600"
    end
  end
end
