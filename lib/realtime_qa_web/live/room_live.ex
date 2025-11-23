defmodule RealtimeQaWeb.RoomLive do
  use RealtimeQaWeb, :live_view
  alias RealtimeQa.{Questions, Rooms}

  def render(assigns) do
    ~H"""
    <%= if @room do %>
      <div class="p-10">
        <!-- ROOM HEADER -->
        <div class="mb-8">
          <div class="flex items-start justify-between mb-4">
            <div class="flex-1">
              <h1 class="text-4xl font-bold mb-2">{@room.title}</h1>
              <p class="text-gray-600 text-lg">{@room.description}</p>
            </div>
            <%= if is_host?(assigns) do %>
              <span class="px-4 py-2 bg-green-100 text-green-800 rounded-full text-sm font-semibold flex items-center gap-2">
                <span>👑</span> Host
              </span>
            <% end %>
          </div>
          <div class="bg-blue-50 border border-blue-200 rounded-lg p-4 inline-block">
            <p class="text-sm text-gray-600 mb-1">Room Code</p>
            <p class="font-mono font-bold text-3xl text-blue-600">{@room.code}</p>
          </div>
        </div>

        <!-- ASK FORM -->
        <div class="mb-8">
          <h2 class="text-2xl font-semibold mb-4">Ask a Question</h2>
          <form phx-submit="add_question">
            <input
              type="text"
              name="question"
              class="w-full bg-white rounded p-3 border border-gray-300"
              placeholder="Type your question..."
              required
            />
            <button class="bg-blue-700 text-lg font-medium text-white px-6 py-2 rounded mt-3 hover:bg-blue-900 transition">
              Submit Question
            </button>
          </form>
        </div>

        <!-- QUESTIONS LIST -->
        <div>
          <div class="flex items-center justify-between mb-4">
            <h2 class="text-2xl font-semibold">Questions ({length(@questions)})</h2>
          </div>

          <div class="space-y-5">
            <%= if Enum.empty?(@questions) do %>
              <div class="text-center py-12 text-gray-500">
                <p class="text-lg">No questions yet. Be the first to ask!</p>
              </div>
            <% else %>
              <%= for q <- @questions do %>
                <div class="bg-white rounded-lg shadow-sm p-7 hover:shadow-md transition-shadow">
                  <div class="flex items-start gap-4">
                    <div class="flex-1 min-w-0">
                      <%= if @editing_question_id == q.id do %>
                        <!-- EDIT MODE -->
                        <form phx-submit="save_edit" phx-value-id={q.id} class="flex items-center gap-2">
                          <input
                            type="text"
                            name="content"
                            value={q.content}
                            class="flex-1 border border-gray-300 rounded p-2 text-gray-800 focus:outline-none focus:ring-2 focus:ring-blue-400"
                            required
                          />
                          <button class="bg-green-600 text-white px-3 py-1 rounded hover:bg-green-700">💾</button>
                          <button type="button" phx-click="cancel_edit" class="bg-gray-300 px-3 py-1 rounded hover:bg-gray-400">✖</button>
                        </form>
                      <% else %>
                        <!-- DISPLAY MODE -->
                        <p class="text-xl text-gray-900">{q.content}</p>
                        <div class="mt-2 flex items-center gap-2 text-sm text-gray-500">
                          <span>Anonymous</span>
                        </div>
                      <% end %>
                    </div>

                    <div class="flex flex-col items-center space-y-2">
                      <!-- UPVOTE BUTTON -->
                      <button
                        phx-click="upvote"
                        phx-value-id={q.id}
                        class={upvote_button_class(q.id, @upvoted_questions)}
                        disabled={is_upvoted?(q.id, @upvoted_questions)}
                      >
                        <%= if is_upvoted?(q.id, @upvoted_questions) do %>
                          <svg
                            class="w-[30px] h-[30px] text-green-600"
                            aria-hidden="true"
                            xmlns="http://www.w3.org/2000/svg"
                            fill="currentColor"
                            viewBox="0 0 24 24"
                          >
                            <path
                              fill-rule="evenodd"
                              d="M15.03 9.684h3.965c.322 0 .64.08.925.232.286.153.532.374.717.645a2.109 2.109 0 0 1 .242 1.883l-2.36 7.201c-.288.814-.48 1.355-1.884 1.355-2.072 0-4.276-.677-6.157-1.256-.472-.145-.924-.284-1.348-.404h-.115V9.478a25.485 25.485 0 0 0 4.238-5.514 1.8 1.8 0 0 1 .901-.83 1.74 1.74 0 0 1 1.21-.048c.396.13.736.397.96.757.225.36.32.788.269 1.211l-1.562 4.63ZM4.177 10H7v8a2 2 0 1 1-4 0v-6.823C3 10.527 3.527 10 4.176 10Z"
                              clip-rule="evenodd"
                            />
                          </svg>
                        <% else %>
                          <svg
                            class="w-[30px] h-[30px]"
                            aria-hidden="true"
                            xmlns="http://www.w3.org/2000/svg"
                            fill="none"
                            viewBox="0 0 24 24"
                          >
                            <path
                              stroke="currentColor"
                              stroke-linecap="round"
                              stroke-linejoin="round"
                              stroke-width="2"
                              d="M7 11c.889-.086 1.416-.543 2.156-1.057a22.323 22.323 0 0 0 3.958-5.084 1.6 1.6 0 0 1 .582-.628 1.549 1.549 0 0 1 1.466-.087c.205.095.388.233.537.406a1.64 1.64 0 0 1 .384 1.279l-1.388 4.114M7 11H4v6.5A1.5 1.5 0 0 0 5.5 19v0A1.5 1.5 0 0 0 7 17.5V11Zm6.5-1h4.915c.286 0 .372.014.626.15.254.135.472.332.637.572a1.874 1.874 0 0 1 .215 1.673l-2.098 6.4C17.538 19.52 17.368 20 16.12 20c-2.303 0-4.79-.943-6.67-1.475"
                            />
                          </svg>
                        <% end %>
                        <span class="text-sm font-medium">{q.upvotes}</span>
                      </button>

                      <!-- HOST ACTION BUTTONS -->
                      <%= if is_host?(assigns) do %>
                        <div class="flex space-x-2 mt-2">
                          <!-- EDIT BUTTON -->
                          <button
                            phx-click="edit_question"
                            phx-value-id={q.id}
                            title="Edit Question"
                            class="p-2 rounded-full hover:bg-blue-50 transition"
                          >
                            <svg class="w-6 h-6 text-blue-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M11 5H6a2 2 0 00-2 2v11a2 2 0 002 2h11a2 2 0 002-2v-5m-1.414-9.414a2 2 0 112.828 2.828L11.828 15H9v-2.828l8.586-8.586z"/>
                            </svg>
                          </button>

                          <!-- DELETE BUTTON -->
                          <button
                            phx-click="delete_question"
                            phx-value-id={q.id}
                            data-confirm="Are you sure you want to delete this question?"
                            title="Delete Question"
                            class="p-2 rounded-full hover:bg-red-50 transition"
                          >
                            <svg class="w-6 h-6 text-red-500" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 7l-.867 12.142A2 2 0 0116.138 21H7.862a2 2 0 01-1.995-1.858L5 7m5 4v6m4-6v6m1-10V4a1 1 0 00-1-1h-4a1 1 0 00-1 1v3M4 7h16"/>
                            </svg>
                          </button>
                        </div>
                      <% end %>
                    </div>
                  </div>
                </div>
              <% end %>
            <% end %>
          </div>
        </div>
      </div>
    <% else %>
      <!-- JOIN ROOM -->
      <div class="min-h-screen flex items-center justify-center bg-gray-50">
        <div class="max-w-md w-full bg-white rounded-lg shadow-lg p-8">
          <h1 class="text-4xl font-bold mb-8 text-center">Join a Room</h1>
          <form phx-submit="join_room" class="space-y-4">
            <div>
              <label class="block text-lg font-medium mb-2">Enter Room Code</label>
              <input
                type="text"
                name="code"
                class="w-full px-4 py-3 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500 text-center text-2xl font-mono uppercase"
                placeholder="ABC123"
                maxlength="6"
                required
              />
            </div>
            <button
              type="submit"
              class="w-full bg-blue-700 text-white text-lg font-medium px-4 py-3 rounded-lg hover:bg-blue-900 transition"
            >
              Join Room
            </button>
          </form>
        </div>
      </div>
    <% end %>
    """
  end

  # lifecycle
  def mount(_params, session, socket) do
    fingerprint = session["user_fingerprint"] || generate_fallback_fingerprint(socket)
    current_user = if session["user_id"], do: RealtimeQa.Auth.get_user(session["user_id"]), else: nil

    {:ok,
      socket
      |> assign(room: nil, questions: [], upvoted_questions: MapSet.new())
      |> assign(user_fingerprint: fingerprint, editing_question_id: nil, current_user: current_user)}
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
    case Rooms.get_room_by_code(String.upcase(code)) do
      nil ->
        {:noreply,
         socket
         |> put_flash(:error, "Room not found")
         |> push_navigate(to: ~p"/")}

      room ->
        # Subscribe to receive realtime broadcasts
        RealtimeQaWeb.Endpoint.subscribe("room:#{room.id}")

        questions = Questions.list_questions(room.id)
        upvoted = Questions.get_upvoted_question_ids(room.id, socket.assigns.user_fingerprint)

        {:noreply,
         socket
         |> assign(room: room, questions: questions, upvoted_questions: upvoted)}
    end
  end

  def handle_params(_params, _uri, socket),
    do: {:noreply, assign(socket, room: nil, questions: [])}

  # events
  def handle_event("join_room", %{"code" => code}, socket),
    do: {:noreply, push_patch(socket, to: ~p"/room/#{String.upcase(code)}")}

  def handle_event("add_question", %{"question" => content}, socket) do
    room = socket.assigns.room

    case Questions.create_question(%{"content" => content, "room_id" => room.id}) do
      {:ok, _} ->
        {:noreply, assign(socket, questions: Questions.list_questions(room.id))}

      {:error, _} ->
        {:noreply, put_flash(socket, :error, "Error creating question")}
    end
  end

  def handle_event("edit_question", %{"id" => id}, socket) do
    if is_host?(socket.assigns) do
      {:noreply, assign(socket, editing_question_id: String.to_integer(id))}
    else
      {:noreply, put_flash(socket, :error, "Only the host can edit questions")}
    end
  end

  def handle_event("cancel_edit", _params, socket),
    do: {:noreply, assign(socket, editing_question_id: nil)}

  def handle_event("save_edit", %{"id" => id, "content" => content}, socket) do
    if is_host?(socket.assigns) do
      question = Questions.get_question!(String.to_integer(id))

      case Questions.update_question(question, %{"content" => content}) do
        {:ok, _} ->
          {:noreply,
           socket
           |> assign(
             questions: Questions.list_questions(socket.assigns.room.id),
             editing_question_id: nil
           )
           |> put_flash(:info, "Question updated")}

        {:error, _} ->
          {:noreply, put_flash(socket, :error, "Failed to update question")}
      end
    else
      {:noreply, put_flash(socket, :error, "Only the host can edit questions")}
    end
  end

  def handle_event("delete_question", %{"id" => id}, socket) do
    if is_host?(socket.assigns) do
      question = Questions.get_question!(String.to_integer(id))
      {:ok, _} = Questions.delete_question(question)

      {:noreply,
       socket
       |> assign(questions: Questions.list_questions(socket.assigns.room.id))
       |> put_flash(:info, "Question deleted")}
    else
      {:noreply, put_flash(socket, :error, "Only the host can delete questions")}
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
        {:ok, _} ->
          new_upvoted = MapSet.put(upvoted, question_id)
          new_questions = Questions.list_questions(socket.assigns.room.id)

          {:noreply,
           socket
           |> assign(questions: new_questions, upvoted_questions: new_upvoted)}

        {:error, _} ->
          {:noreply, put_flash(socket, :error, "Failed to upvote")}
      end
    end
  end

  # Handle broadcasts from PubSub
  def handle_info(
        %Phoenix.Socket.Broadcast{event: "question_created", payload: %{question: _question}},
        socket
      ) do
    room = socket.assigns.room
    {:noreply, assign(socket, questions: Questions.list_questions(room.id))}
  end

  def handle_info(
        %Phoenix.Socket.Broadcast{event: "question_upvoted", payload: %{question: _question}},
        socket
      ) do
    room = socket.assigns.room
    {:noreply, assign(socket, questions: Questions.list_questions(room.id))}
  end

  def handle_info(
        %Phoenix.Socket.Broadcast{event: "question_deleted", payload: %{question_id: _id}},
        socket
      ) do
    room = socket.assigns.room
    {:noreply, assign(socket, questions: Questions.list_questions(room.id))}
  end

  def handle_info(
        %Phoenix.Socket.Broadcast{event: "question_updated", payload: %{question: _question}},
        socket
      ) do
    room = socket.assigns.room
    {:noreply, assign(socket, questions: Questions.list_questions(room.id))}
  end

  # helpers
  defp extract_ip(%{address: address}),
    do: address |> Tuple.to_list() |> Enum.join(".")

  defp extract_ip(_), do: "unknown"

  defp is_upvoted?(question_id, upvoted_set),
    do: MapSet.member?(upvoted_set, question_id)

  defp upvote_button_class(question_id, upvoted_set) do
    if is_upvoted?(question_id, upvoted_set),
      do: "flex flex-col items-center text-green-600 cursor-not-allowed",
      else: "flex flex-col items-center text-gray-600 hover:text-gray-800 cursor-pointer"
  end

  defp is_host?(assigns) do
    assigns[:current_user] && assigns[:room] &&
      assigns.current_user.id == assigns.room.host_id
  end
end
