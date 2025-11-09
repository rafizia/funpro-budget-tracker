defmodule RealtimeQa.Questions do
  import Ecto.Query, warn: false
  alias RealtimeQa.Repo
  alias RealtimeQa.Question

  def list_questions(room_id) do
    Repo.all(from q in Question,
      where: q.room_id == ^room_id,
      order_by: [desc: q.inserted_at])
  end

  def create_question(attrs \\ %{}) do
    %Question{}
    |> Question.changeset(attrs)
    |> Repo.insert()
  end

  def upvote_question(id) do
    {_, _} = Repo.update_all(from(q in Question, where: q.id == ^id), inc: [upvotes: 1])
    Repo.get!(Question, id)
  end

  def decrement_upvote_question(id) do
    Repo.update_all(from(q in Question, where: q.id == ^id and q.upvotes > 0), inc: [upvotes: -1])
    Repo.get!(Question, id)
  end
end
