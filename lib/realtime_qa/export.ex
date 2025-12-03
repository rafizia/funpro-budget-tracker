defmodule RealtimeQa.Export do
  def generate_csv_content(questions) do
    header = "ID,Waktu,Pertanyaan,Upvotes\n"

    # Stream data
    rows =
      questions
      |> Stream.map(fn q ->
        timestamp = Calendar.strftime(q.inserted_at, "%Y-%m-%d %H:%M:%S")

        question = String.replace(q.content, "\"", "\"\"")

        "#{q.id},#{timestamp},\"#{question}\",#{q.upvotes}\n"
      end)

    Stream.concat([header], rows)
    |> Enum.into("")
  end
end
