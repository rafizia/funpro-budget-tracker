defmodule RealtimeQa.Questions do
  import Ecto.Query, warn: false
  alias RealtimeQa.Repo
  alias RealtimeQa.Question

  def list_questions do
    Repo.all(from q in Question, order_by: [desc: q.inserted_at])
  end

  def create_question(attrs \\ %{}) do
    %Question{}
    |> Question.changeset(attrs)
    |> Repo.insert()
  end
end
