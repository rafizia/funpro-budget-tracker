defmodule RealtimeQa.Questions do
  import Ecto.Query, warn: false
  alias RealtimeQa.Repo
  alias RealtimeQa.{Question, QuestionUpvote}

  def toggle_prioritize(%Question{} = question) do
    new_priority = !question.is_prioritized

    multi =
      Ecto.Multi.new()
      |> maybe_unprioritize_all(question, new_priority)
      |> Ecto.Multi.update(
        :update_question,
        Question.prioritize_changeset(question, %{is_prioritized: new_priority})
      )

    case Repo.transaction(multi) do
      {:ok, %{update_question: updated_question}} ->
        broadcast_prioritize_change(updated_question.room_id).(updated_question)
      {:error, _step, reason, _changes_so_far} ->
        {:error, reason}
    end
  end

  defp maybe_unprioritize_all(multi, %Question{room_id: room_id}, true) do
    Ecto.Multi.update_all(
      multi,
      :unprioritize_all,
      from(q in Question, where: q.room_id == ^room_id and q.is_prioritized == true),
      set: [is_prioritized: false]
    )
  end

  defp maybe_unprioritize_all(multi, _question, false), do: multi

  defp broadcast_prioritize_change(room_id) do
    fn updated_question ->
      RealtimeQaWeb.Endpoint.broadcast("room:#{room_id}", "question_prioritized", %{
        question: updated_question
      })
      {:ok, updated_question}
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
