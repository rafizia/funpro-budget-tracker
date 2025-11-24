defmodule RealtimeQa.Questions do
  import Ecto.Query, warn: false
  alias RealtimeQa.Repo
  alias RealtimeQa.{Question, QuestionUpvote}

  defp unprioritize_all_in_room(room_id) do
    fn ->
      Repo.update_all(
        from(q in Question, where: q.room_id == ^room_id and q.is_prioritized == true),
        set: [is_prioritized: false]
      )
    end
  end

  defp update_question_priority(question, new_priority_value) do
    fn ->
      question
      |> Question.prioritize_changeset(%{is_prioritized: new_priority_value})
      |> Repo.update()
    end
  end

  defp broadcast_prioritize_change(room_id) do
    fn updated_question ->
      RealtimeQaWeb.Endpoint.broadcast("room:#{room_id}", "question_prioritized", %{
        question: updated_question
      })
      {:ok, updated_question}
    end
  end

  defp compose_prioritize_transaction(question) do
    new_priority = !question.is_prioritized
    operations = if new_priority do
      [
        unprioritize_all_in_room(question.room_id),
        update_question_priority(question, new_priority)
      ]
    else
      [
        update_question_priority(question, new_priority)
      ]
    end

    fn ->
      Enum.reduce_while(operations, {:ok, nil}, fn operation, _acc ->
        case operation.() do
          {:error, reason} ->
            {:halt, {:error, reason}}
          {count, _nil} when is_integer(count) ->
            {:cont, {:ok, :continue}}
          {:ok, result} ->
            {:cont, {:ok, result}}
        end
      end)
    end
  end

  def toggle_prioritize(%Question{} = question) do
    composed_transaction = compose_prioritize_transaction(question)

    result = Repo.transaction(fn ->
      case composed_transaction.() do
        {:ok, updated_question} when is_struct(updated_question, Question) ->
          updated_question
        {:ok, :continue} ->
          Repo.get!(Question, question.id)
        {:error, changeset} ->
          Repo.rollback(changeset)
      end
    end)

    case result do
      {:ok, updated_question} ->
        broadcast_fn = broadcast_prioritize_change(question.room_id)
        broadcast_fn.(updated_question)
      error ->
        error
    end
  end

  def list_questions(room_id) do
    Repo.all(
      from q in Question,
        where: q.room_id == ^room_id,
        order_by: [desc: q.is_prioritized, desc: q.upvotes, desc: q.inserted_at]
    )
  end

  def create_question(attrs \\ %{}) do
    %Question{}
    |> Question.changeset(attrs)
    |> Repo.insert()
    |> case do
      {:ok, question} ->
        RealtimeQaWeb.Endpoint.broadcast("room:#{question.room_id}", "question_created", %{
          question: question
        })

        {:ok, question}

      {:error, changeset} ->
        {:error, changeset}
    end
  end

  def get_question!(id), do: Repo.get!(Question, id)

  def update_question(%Question{} = question, attrs) do
    question
    |> Question.changeset(attrs)
    |> Repo.update()
    |> case do
      {:ok, updated_question} ->
        RealtimeQaWeb.Endpoint.broadcast("room:#{updated_question.room_id}", "question_updated", %{
          question: updated_question
        })

        {:ok, updated_question}

      error ->
        error
    end
  end

  def delete_question(%Question{} = question) do
    case Repo.delete(question) do
      {:ok, deleted_question} ->
        RealtimeQaWeb.Endpoint.broadcast("room:#{deleted_question.room_id}", "question_deleted", %{
          question_id: deleted_question.id
        })

        {:ok, deleted_question}

      error ->
        error
    end
  end

  def add_upvote(question_id, user_fingerprint) do
    case Repo.transaction(fn ->
           case insert_upvote_record(question_id, user_fingerprint) do
             {:ok, _upvote} -> increment_upvote_count(question_id)
             {:error, changeset} -> Repo.rollback(changeset)
           end
         end) do
      {:ok, question} ->
        RealtimeQaWeb.Endpoint.broadcast("room:#{question.room_id}", "question_upvoted", %{
          question: question
        })

        {:ok, question}

      {:error, reason} ->
        {:error, reason}
    end
  end

  def has_upvoted?(question_id, user_fingerprint) do
    Repo.exists?(
      from u in QuestionUpvote,
        where: u.question_id == ^question_id and u.user_fingerprint == ^user_fingerprint
    )
  end

  def get_upvoted_question_ids(room_id, user_fingerprint) do
    Repo.all(
      from u in QuestionUpvote,
        join: q in Question,
        on: u.question_id == q.id,
        where: q.room_id == ^room_id and u.user_fingerprint == ^user_fingerprint,
        select: u.question_id
    )
    |> MapSet.new()
  end

  defp insert_upvote_record(question_id, user_fingerprint) do
    %QuestionUpvote{}
    |> QuestionUpvote.changeset(%{
      question_id: question_id,
      user_fingerprint: user_fingerprint
    })
    |> Repo.insert()
  end

  defp increment_upvote_count(question_id) do
    {1, _} =
      Repo.update_all(
        from(q in Question, where: q.id == ^question_id),
        inc: [upvotes: 1]
      )

    Repo.get!(Question, question_id)
  end
end
