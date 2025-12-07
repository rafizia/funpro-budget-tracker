defmodule RealtimeQaWeb.RoomLive do
  use RealtimeQaWeb, :live_view
  alias RealtimeQa.{Questions, Rooms}

  def render(assigns) do
    ~H"""
    <div class="min-h-screen bg-slate-50 text-slate-900 font-sans pb-24">

      <%= if @room do %>
        <header class="bg-white border-b border-slate-200 sticky top-0 z-20 shadow-sm">
          <div class="max-w-4xl mx-auto px-4 sm:px-6 py-4">
            <div class="flex items-center justify-between">
              <div class="flex-1 min-w-0 mr-4">
                <div class="flex items-center gap-3">
                  <h1 class="text-xl sm:text-2xl font-bold tracking-tight text-slate-900 truncate">
                    {@room.title}
                  </h1>
                  <%= if is_host?(assigns) do %>
                    <span class="inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium bg-indigo-100 text-indigo-800 border border-indigo-200">
                      Host View
                    </span>
                  <% end %>
                </div>
                <p class="text-sm text-slate-500 truncate mt-1">{@room.description}</p>
              </div>

              <div class="flex items-center gap-4 shrink-0">
                <div class="flex flex-col items-end">
                  <span class="text-[10px] uppercase font-bold text-slate-400 tracking-wider">Room Code</span>
                  <span class="font-mono text-2xl font-bold text-indigo-600 leading-none">{@room.code}</span>
                </div>
              </div>
            </div>
          </div>
        </header>

        <main class="max-w-6xl mx-auto px-4 sm:px-6 mt-8 sm:mt-10">
          <div class="grid grid-cols-1 lg:grid-cols-3 gap-8">
            <!-- Left Column: Questions -->
            <div class="lg:col-span-2">
              <%= unless is_host?(assigns) do %>
                <div class="mb-12">
                  <form phx-submit="add_question" class="relative group">
                    <div class="
                      bg-white rounded-xl border border-slate-200
                      overflow-hidden transition-all duration-200
                      focus-within:shadow-lg focus-within:border-indigo-500 focus-within:ring-indigo-500/10
                    ">
                      <textarea
                        name="question"
                        rows="3"
                        class="
                          w-full border-0 bg-transparent p-5 text-lg text-slate-800
                          placeholder:text-slate-400 resize-none outline-none
                        "
                        placeholder="Type your question..."
                        required
                      ></textarea>

                      <div class="bg-slate-50 px-4 py-3 border-t border-slate-200 flex justify-between items-center">
                        <div class="flex items-center gap-2 text-slate-500">
                          <div class="w-6 h-6 rounded-full bg-slate-200 flex items-center justify-center">
                            <svg xmlns="http://www.w3.org/2000/svg" class="w-3 h-3 text-slate-500" viewBox="0 0 20 20" fill="currentColor">
                              <path fill-rule="evenodd" d="M10 9a3 3 0 100-6 3 3 0 000 6zm-7 9a7 7 0 1114 0H3z" clip-rule="evenodd" />
                            </svg>
                          </div>
                          <span class="text-xs font-semibold">Anonymous</span>
                        </div>
                        <button class="
                          bg-indigo-600 hover:bg-indigo-700 text-white
                          px-5 py-2 rounded-lg text-sm font-bold
                          shadow-sm shadow-indigo-200 transition-all
                          flex items-center gap-2 active:scale-95
                        ">
                          <span>Send</span>
                          <svg xmlns="http://www.w3.org/2000/svg" class="w-4 h-4" viewBox="0 0 20 20" fill="currentColor">
                            <path d="M10.894 2.553a1 1 0 00-1.788 0l-7 14a1 1 0 001.169 1.409l5-1.429A1 1 0 009 15.571V11a1 1 0 112 0v4.571a1 1 0 00.725.962l5 1.428a1 1 0 001.17-1.408l-7-14z" />
                          </svg>
                        </button>
                      </div>
                    </div>
                  </form>
                </div>
              <% end %>

              <div>
                <div class="flex items-center justify-between mb-6 px-1">
                  <h2 class="text-xl font-bold text-slate-800 flex items-center gap-2">
                    Questions
                    <span class="bg-slate-200 text-slate-600 text-xs font-bold py-1 px-2 rounded-full">
                      {length(@questions)}
                    </span>
                  </h2>
                  <div class="text-xs font-medium text-slate-400 uppercase tracking-wider">Top Voted</div>
                </div>

                <div class="space-y-5"> <%= if Enum.empty?(@questions) do %>
                    <div class="text-center py-16 bg-white rounded-2xl border border-dashed border-slate-300">
                      <div class="mx-auto w-12 h-12 bg-slate-50 rounded-full flex items-center justify-center mb-3">
                        <svg xmlns="http://www.w3.org/2000/svg" class="w-6 h-6 text-slate-300" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M8 12h.01M12 12h.01M16 12h.01M21 12c0 4.418-4.03 8-9 8a9.863 9.863 0 01-4.255-.949L3 20l1.395-3.72C3.512 15.042 3 13.574 3 12c0-4.418 4.03-8 9-8s9 3.582 9 8z" />
                        </svg>
                      </div>
                      <p class="text-slate-500 font-medium">No questions yet.</p>
                      <p class="text-sm text-slate-400">Waiting for the audience...</p>
                    </div>
                  <% else %>
                    <%= for q <- @questions do %>
                      <div class={question_card_class(q.is_prioritized)}>

                        <div class="flex flex-col items-center shrink-0 pt-1">
                          <button
                            phx-click="upvote"
                            phx-value-id={q.id}
                            disabled={is_upvoted?(q.id, @upvoted_questions)}
                            class="group/upvote flex flex-col items-center gap-1 transition-all"
                          >
                            <div class={if is_upvoted?(q.id, @upvoted_questions),
                                do: "bg-green-100 text-green-600 shadow-sm border border-green-200 w-11 h-11 flex items-center justify-center rounded-xl transition-all",
                                else: "bg-slate-50 border border-slate-200 text-slate-400 group-hover/upvote:border-indigo-300 group-hover/upvote:text-indigo-600 group-hover/upvote:shadow-md w-11 h-11 flex items-center justify-center rounded-xl transition-all"}>
                              <svg xmlns="http://www.w3.org/2000/svg" class="w-6 h-6" viewBox="0 0 20 20" fill="currentColor">
                                <path fill-rule="evenodd" d="M3.293 9.707a1 1 0 010-1.414l6-6a1 1 0 011.414 0l6 6a1 1 0 01-1.414 1.414L11 5.414V17a1 1 0 11-2 0V5.414L4.707 9.707a1 1 0 01-1.414 0z" clip-rule="evenodd" />
                              </svg>
                            </div>
                            <span class={if is_upvoted?(q.id, @upvoted_questions),
                                do: "text-sm font-bold text-green-700",
                                else: "text-sm font-bold text-slate-500 group-hover/upvote:text-indigo-600"}>
                              {q.upvotes}
                            </span>
                          </button>
                        </div>

                        <div class="flex-1 min-w-0 flex flex-col">
                          <%= if @editing_question_id == q.id do %>
                            <form phx-submit="save_edit" phx-value-id={q.id} class="w-full">
                              <textarea
                                name="content"
                                class="w-full border-indigo-300 rounded-lg p-3 text-slate-800 focus:ring-2 focus:ring-indigo-200 focus:border-indigo-500 text-lg min-h-[120px] shadow-sm"
                                required
                              >{q.content}</textarea>
                              <div class="flex gap-2 mt-3 justify-end">
                                <button type="button" phx-click="cancel_edit" class="text-xs font-bold text-slate-500 hover:text-slate-800 px-3 py-2 rounded hover:bg-slate-100">Cancel</button>
                                <button class="bg-indigo-600 text-white px-4 py-2 rounded-lg text-xs font-bold hover:bg-indigo-700 shadow-sm">Save Changes</button>
                              </div>
                            </form>
                          <% else %>
                            <div>
                              <p class="text-lg sm:text-xl text-slate-800 leading-relaxed break-words">{q.content}</p>

                              <div class="mt-3 flex items-center gap-3">
                                <div class="flex items-center gap-2">
                                  <span class="w-1.5 h-1.5 rounded-full bg-slate-300"></span>
                                  <span class="text-xs font-medium text-slate-400">Anonymous</span>
                                </div>
                                <%= if q.is_prioritized do %>
                                  <span class="flex items-center gap-1.5 px-2.5 py-1 bg-amber-100 text-amber-800 border border-amber-200 rounded text-[11px] font-bold uppercase tracking-wide shadow-sm">
                                    <svg xmlns="http://www.w3.org/2000/svg" class="w-3 h-3 text-amber-600" viewBox="0 0 20 20" fill="currentColor">
                                      <path d="M9.049 2.927c.3-.921 1.603-.921 1.902 0l1.07 3.292a1 1 0 00.95.69h3.462c.969 0 1.371 1.24.588 1.81l-2.8 2.034a1 1 0 00-.364 1.118l1.07 3.292c.3.921-.755 1.688-1.54 1.118l-2.8-2.034a1 1 0 00-1.175 0l-2.8 2.034c-.784.57-1.838-.197-1.539-1.118l1.07-3.292a1 1 0 00-.364-1.118L2.98 8.72c-.783-.57-.38-1.81.588-1.81h3.461a1 1 0 00.951-.69l1.07-3.292z" />
                                    </svg>
                                    Pinned Question
                                  </span>
                                <% end %>
                              </div>
                            </div>
                          <% end %>
                        </div>

                        <%= if (is_host?(assigns) || q.user_fingerprint == @user_fingerprint) && @editing_question_id != q.id do %>
                          <div class="flex flex-col gap-2 opacity-100 sm:opacity-0 group-hover:opacity-100 transition-opacity duration-200 shrink-0 ml-2">

                            <%= if is_host?(assigns) do %>
                              <button
                                phx-click="toggle_prioritize"
                                phx-value-id={q.id}
                                title={if q.is_prioritized, do: "Unpin", else: "Pin"}
                                class={"w-9 h-9 flex items-center justify-center rounded-lg transition-all border " <>
                                  if(q.is_prioritized,
                                    do: "bg-amber-100 text-amber-700 border-amber-200 hover:bg-amber-200 shadow-sm",
                                    else: "text-slate-400 hover:text-amber-600 hover:bg-amber-50 border-transparent hover:border-amber-100")
                                }
                              >
                                <%= if q.is_prioritized do %>
                                  <svg xmlns="http://www.w3.org/2000/svg" class="w-5 h-5" viewBox="0 0 20 20" fill="currentColor">
                                    <path fill-rule="evenodd" d="M10 18a8 8 0 100-16 8 8 0 000 16zM8.707 7.293a1 1 0 00-1.414 1.414L8.586 10l-1.293 1.293a1 1 0 101.414 1.414L10 11.414l1.293 1.293a1 1 0 001.414-1.414L11.414 10l1.293-1.293a1 1 0 00-1.414-1.414L10 8.586 8.707 7.293z" clip-rule="evenodd" />
                                  </svg>
                                <% else %>
                                  <svg xmlns="http://www.w3.org/2000/svg" class="w-5 h-5" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M11.049 2.927c.3-.921 1.603-.921 1.902 0l1.519 4.674a1 1 0 00.95.69h4.915c.969 0 1.371 1.24.588 1.81l-3.976 2.888a1 1 0 00-.363 1.118l1.518 4.674c.3.922-.755 1.688-1.538 1.118l-3.976-2.888a1 1 0 00-1.176 0l-3.976 2.888c-.783.57-1.838-.197-1.538-1.118l1.518-4.674a1 1 0 00-.363-1.118l-3.976-2.888c-.784-.57-.38-1.81.588-1.81h4.914a1 1 0 00.951-.69l1.519-4.674z" />
                                  </svg>
                                <% end %>
                              </button>
                            <% end %>

                            <button
                              phx-click="edit_question"
                              phx-value-id={q.id}
                              title="Edit"
                              class="w-9 h-9 flex items-center justify-center rounded-lg text-indigo-600 bg-indigo-50 hover:bg-indigo-100 border border-transparent hover:border-indigo-200 transition-all"
                            >
                              <svg xmlns="http://www.w3.org/2000/svg" class="w-5 h-5" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15.232 5.232l3.536 3.536m-2.036-5.036a2.5 2.5 0 113.536 3.536L6.5 21.036H3v-3.572L16.732 3.732z" />
                              </svg>
                            </button>

                            <button
                              phx-click="delete_question"
                              phx-value-id={q.id}
                              data-confirm="Delete this question?"
                              title="Delete"
                              class="w-9 h-9 flex items-center justify-center rounded-lg text-rose-600 bg-rose-50 hover:bg-rose-100 border border-transparent hover:border-rose-200 transition-all"
                            >
                              <svg xmlns="http://www.w3.org/2000/svg" class="w-5 h-5" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 7l-.867 12.142A2 2 0 0116.138 21H7.862a2 2 0 01-1.995-1.858L5 7m5 4v6m4-6v6m1-10V4a1 1 0 00-1-1h-4a1 1 0 00-1 1v3M4 7h16" />
                              </svg>
                            </button>
                          </div>
                        <% end %>

                      </div>
                    <% end %>
                  <% end %>
                </div>
              </div>
            </div>

            <!-- Right Column: Sticky QR Code -->
            <div class="hidden lg:block lg:col-span-1">
              <div class="sticky top-24">
                <div class="bg-white rounded-xl border border-slate-200 p-6 flex flex-col items-center text-center">
                  <h3 class="text-lg font-bold text-slate-800 mb-2">Join the Room</h3>
                  <p class="text-sm text-slate-500 mb-6">Scan to join on your phone</p>

                  <div class="bg-white p-2 rounded-xl border border-slate-100 shadow-inner mb-6">
                    <%= (RealtimeQaWeb.Endpoint.url() <> ~p"/room/#{@room.code}") |> EQRCode.encode() |> EQRCode.svg(width: 180) |> Phoenix.HTML.raw() %>
                  </div>

                  <div class="w-full bg-slate-50 rounded-xl p-4 border border-slate-100">
                    <p class="text-xs font-bold text-slate-400 uppercase tracking-wider mb-1">Room Code</p>
                    <p class="font-mono text-3xl font-bold text-indigo-600 tracking-wider">{@room.code}</p>
                  </div>
                </div>
              </div>
            </div>
          </div>
        </main>

      <% else %>
        <div class="min-h-screen flex items-center justify-center bg-gradient-to-br from-indigo-600 to-violet-700 p-4">
          <div class="max-w-md w-full bg-white/10 backdrop-blur-lg rounded-3xl shadow-2xl p-8 border border-white/20 text-white">
            <div class="text-center mb-10">
              <h1 class="text-4xl font-extrabold tracking-tight mb-2">Realtime QA</h1>
              <p class="text-indigo-100 text-lg">Join the conversation</p>
            </div>

            <form phx-submit="join_room" class="space-y-6">
              <div>
                <label class="block text-xs font-bold mb-2 text-indigo-100 uppercase tracking-widest">Room Code</label>
                <input
                  type="text"
                  name="code"
                  class="w-full px-4 py-4 bg-white/20 border-2 border-white/10 rounded-xl focus:ring-4 focus:ring-white/20 focus:border-white text-center text-3xl font-mono font-bold uppercase tracking-widest placeholder:text-white/30 text-white transition-all outline-none"
                  placeholder="ABC123"
                  maxlength="6"
                  required
                />
              </div>
              <button
                type="submit"
                class="w-full bg-white text-indigo-600 text-lg font-bold px-4 py-4 rounded-xl hover:bg-indigo-50 hover:scale-[1.02] transition-all shadow-lg shadow-indigo-900/20"
              >
                Enter Room &rarr;
              </button>
            </form>
          </div>
        </div>
      <% end %>

    </div>
    """
  end

  # --- LIFECYCLE ---
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

  # --- EVENTS ---
  def handle_event("join_room", %{"code" => code}, socket),
    do: {:noreply, push_patch(socket, to: ~p"/room/#{String.upcase(code)}")}

  def handle_event("add_question", %{"question" => content}, socket) do
    room = socket.assigns.room
    user_fingerprint = socket.assigns.user_fingerprint

    case Questions.create_question(%{
           "content" => content,
           "room_id" => room.id,
           "user_fingerprint" => user_fingerprint
         }) do
      {:ok, _} ->
        {:noreply, assign(socket, questions: Questions.list_questions(room.id))}

      {:error, _} ->
        {:noreply, put_flash(socket, :error, "Error creating question")}
    end
  end

  def handle_event("edit_question", %{"id" => id}, socket) do
    question = Questions.get_question!(String.to_integer(id))
    if is_host?(socket.assigns) || question.user_fingerprint == socket.assigns.user_fingerprint do
      {:noreply, assign(socket, editing_question_id: question.id)}
    else
      {:noreply, put_flash(socket, :error, "You can only edit your own questions")}
    end
  end

  def handle_event("cancel_edit", _params, socket),
    do: {:noreply, assign(socket, editing_question_id: nil)}

  def handle_event("save_edit", %{"id" => id, "content" => content}, socket) do
    question = Questions.get_question!(String.to_integer(id))
    if is_host?(socket.assigns) || question.user_fingerprint == socket.assigns.user_fingerprint do
      case Questions.update_question(question, %{"content" => content}) do
        {:ok, _} ->
          {:noreply,
           socket
           |> assign(questions: Questions.list_questions(socket.assigns.room.id), editing_question_id: nil)
           |> put_flash(:info, "Question updated")}
        {:error, _} ->
          {:noreply, put_flash(socket, :error, "Failed to update question")}
      end
    else
      {:noreply, put_flash(socket, :error, "You can only edit your own questions")}
    end
  end

  def handle_event("delete_question", %{"id" => id}, socket) do
    question = Questions.get_question!(String.to_integer(id))
    if is_host?(socket.assigns) || question.user_fingerprint == socket.assigns.user_fingerprint do
      {:ok, _} = Questions.delete_question(question)
      {:noreply,
       socket
       |> assign(questions: Questions.list_questions(socket.assigns.room.id))
       |> put_flash(:info, "Question deleted")}
    else
      {:noreply, put_flash(socket, :error, "You can only delete your own questions")}
    end
  end

  def handle_event("toggle_prioritize", %{"id" => id}, socket) do
    if is_host?(socket.assigns) do
      question = Questions.get_question!(String.to_integer(id))
      case Questions.toggle_prioritize(question) do
        {:ok, updated_question} ->
          flash = if updated_question.is_prioritized, do: "Question prioritized", else: "Question unprioritized"
          {:noreply,
           socket
           |> assign(questions: Questions.list_questions(socket.assigns.room.id))
           |> put_flash(:info, flash)}
        {:error, _} ->
          {:noreply, put_flash(socket, :error, "Failed to toggle priority")}
      end
    else
      {:noreply, put_flash(socket, :error, "Only the host can prioritize questions")}
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
          {:noreply, assign(socket, questions: new_questions, upvoted_questions: new_upvoted)}
        {:error, _} ->
          {:noreply, put_flash(socket, :error, "Failed to upvote")}
      end
    end
  end

  # --- PUBSUB HANDLERS ---
  def handle_info(%Phoenix.Socket.Broadcast{event: "question_created"}, socket) do
    {:noreply, assign(socket, questions: Questions.list_questions(socket.assigns.room.id))}
  end

  def handle_info(%Phoenix.Socket.Broadcast{event: "question_upvoted"}, socket) do
    {:noreply, assign(socket, questions: Questions.list_questions(socket.assigns.room.id))}
  end

  def handle_info(%Phoenix.Socket.Broadcast{event: "question_deleted"}, socket) do
    {:noreply, assign(socket, questions: Questions.list_questions(socket.assigns.room.id))}
  end

  def handle_info(%Phoenix.Socket.Broadcast{event: "question_updated"}, socket) do
    {:noreply, assign(socket, questions: Questions.list_questions(socket.assigns.room.id))}
  end

  def handle_info(%Phoenix.Socket.Broadcast{event: "question_prioritized"}, socket) do
    {:noreply, assign(socket, questions: Questions.list_questions(socket.assigns.room.id))}
  end

  # --- HELPERS ---
  defp extract_ip(%{address: address}), do: address |> Tuple.to_list() |> Enum.join(".")
  defp extract_ip(_), do: "unknown"

  defp is_upvoted?(question_id, upvoted_set), do: MapSet.member?(upvoted_set, question_id)

  defp is_host?(assigns) do
    assigns[:current_user] && assigns[:room] && assigns.current_user.id == assigns.room.host_id
  end

  defp question_card_class(is_prioritized) do
    # Increased padding (p-6) and gap (gap-5) for bigger feel
    base = "group relative flex items-start gap-5 p-6 bg-white rounded-xl border transition-all duration-200"
    hover = "hover:shadow-lg hover:border-indigo-200"

    state =
      if is_prioritized do
        # Strong Left Border + Gold Tint + Permanent Shadow
        "border-l-4 border-l-amber-500 border-y-amber-200 border-r-amber-200 bg-amber-50/50 shadow-md shadow-amber-100/50"
      else
        "border-slate-200"
      end

    "#{base} #{hover} #{state}"
  end
end
