defmodule RealtimeQaWeb.ExportController do
  use RealtimeQaWeb, :controller
  alias RealtimeQa.Rooms
  alias RealtimeQa.Questions
  alias RealtimeQa.Export

  def export_room_questions(conn, %{"id" => id}) do
    room = Rooms.get_room!(id)

    if room.host_id == conn.assigns.current_user.id do
      questions = Questions.list_questions(room.id)
      csv_content = Export.generate_csv_content(questions)
      filename = "questions_#{room.code}_#{Calendar.strftime(DateTime.utc_now(), "%Y%m%d_%H%M%S")}.csv"

      conn
      |> put_resp_content_type("text/csv")
      |> put_resp_header("content-disposition", "attachment; filename=\"#{filename}\"")
      |> send_resp(200, csv_content)
    else
      conn
      |> put_flash(:error, "Unauthorized")
      |> redirect(to: ~p"/dashboard")
    end
  end
end
