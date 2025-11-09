defmodule RealtimeQaWeb.Question do
  use RealtimeQaWeb, :live_view
  alias RealtimeQa.Questions

  def render(assigns) do
    ~H"""
    <div class="p-10">
      <h1 class="text-4xl font-bold mb-10">Realtime Q&A</h1>

      <h2 class="text-2xl font-semibold mb-2">Tambah Pertanyaan</h2>

      <form phx-submit="add_question">
        <input
          class="border rounded p-2 w-full"
          type="text"
          name="question"
          placeholder="Tulis pertanyaan..."
        /> <button class="bg-blue-500 text-white px-4 py-2 rounded mt-2" type="submit">Kirim</button>
      </form>

      <div>
        <h2 class="text-2xl font-semibold mt-4">Daftar Pertanyaan</h2>

        <ul>
          <%= for q <- @questions do %>
            <li class="flex items-center justify-between border-b py-2">
              <span>{q.content}</span>
              <div class="flex items-center space-x-2 text-gray-600">
                <button phx-click="upvote" phx-value-id={q.id} class="px-2 py-1 bg-green-100 rounded">👍 {q.upvotes}</button>
              </div>
            </li>
          <% end %>
        </ul>
      </div>
    </div>
    """
  end

  def mount(_params, _session, socket) do
    {:ok, assign(socket, questions: Questions.list_questions(), voted: MapSet.new())}
  end

  def handle_event("add_question", %{"question" => question}, socket) do
    Questions.create_question(%{content: question})
    {:noreply, assign(socket, questions: Questions.list_questions())}
  end

  def handle_event("upvote", %{"id" => id}, socket) do
    voted = socket.assigns[:voted] || MapSet.new()

    if MapSet.member?(voted, id) do
      Questions.decrement_upvote_question(id)
      new_voted = MapSet.delete(voted, id)
      {:noreply, assign(socket, questions: Questions.list_questions(), voted: new_voted)}
    else
      Questions.upvote_question(id)
      new_voted = MapSet.put(voted, id)
      {:noreply, assign(socket, questions: Questions.list_questions(), voted: new_voted)}
    end
  end
end
