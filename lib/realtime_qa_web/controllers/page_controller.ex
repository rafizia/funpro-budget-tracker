defmodule RealtimeQaWeb.PageController do
  use RealtimeQaWeb, :controller

  def home(conn, _params) do
    render(conn, :home)
  end
end
