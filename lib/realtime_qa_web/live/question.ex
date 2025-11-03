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
        />
        <button class="bg-blue-500 text-white px-4 py-2 rounded mt-2" type="submit">Kirim</button>
      </form>

      <div>
        <h2 class="text-2xl font-semibold mt-4">Daftar Pertanyaan</h2>

        <ul>
          <%= for q <- @questions do %>
            <li class="flex items-center justify-between border-b py-2">
              <span><%= q.content %></span>
              <div class="flex items-center space-x-2 text-gray-600">
                <button phx-click="edit_question" phx-value-id={q.id}>✏️</button>
                <button phx-click="delete_question" phx-value-id={q.id}>🗑️</button>
              </div>
            </li>
          <% end %>
        </ul>
      </div>

      <%= if @editing_question do %>
        <div class="mt-6 border-t pt-4">
          <h2 class="text-xl font-semibold mb-2">Edit Pertanyaan</h2>
          <form phx-submit="update_question">
            <input type="hidden" name="id" value={@editing_question.id} />
            <input
              class="border rounded p-2 w-full"
              type="text"
              name="content"
              value={@editing_question.content}
            />
            <button class="bg-green-500 text-white px-4 py-2 rounded mt-2" type="submit">Update</button>
          </form>
        </div>
      <% end %>
    </div>
    """
  end

  def mount(_params, _session, socket) do
    {:ok,
     assign(socket,
       questions: Questions.list_questions(),
       editing_question: nil
     )}
  end

  def handle_event("add_question", %{"question" => question}, socket) do
    Questions.create_question(%{content: question, upvotes: 0})
    {:noreply, assign(socket, questions: Questions.list_questions())}
  end

  def handle_event("edit_question", %{"id" => id}, socket) do
    question = Questions.get_question!(id)
    {:noreply, assign(socket, editing_question: question)}
  end

  def handle_event("update_question", %{"id" => id, "content" => content}, socket) do
    question = Questions.get_question!(id)
    Questions.update_question(question, %{content: content})
    {:noreply,
     assign(socket,
       questions: Questions.list_questions(),
       editing_question: nil
     )}
  end

  def handle_event("delete_question", %{"id" => id}, socket) do
    question = Questions.get_question!(id)
    Questions.delete_question(question)
    {:noreply, assign(socket, questions: Questions.list_questions())}
  end
end
