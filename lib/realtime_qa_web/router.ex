# lib/realtime_qa_web/router.ex
defmodule RealtimeQaWeb.Router do
  use RealtimeQaWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {RealtimeQaWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug :put_user_fingerprint
    plug :fetch_current_user
  end

  pipeline :require_auth do
    plug :require_authenticated_user
  end

  defp put_user_fingerprint(conn, _opts) do
    case conn.req_cookies["user_fingerprint"] do
      nil ->
        fingerprint = generate_persistent_fingerprint()

        conn
        |> put_resp_cookie("user_fingerprint", fingerprint,
            max_age: 365 * 24 * 60 * 60,
            http_only: true,
            same_site: "Lax"
          )
        |> put_session(:user_fingerprint, fingerprint)

      fingerprint ->
        put_session(conn, :user_fingerprint, fingerprint)
    end
  end

  defp fetch_current_user(conn, _opts) do
    case get_session(conn, :user_id) do
      nil ->
        assign(conn, :current_user, nil)
      user_id ->
        user = RealtimeQa.Auth.get_user(user_id)
        assign(conn, :current_user, user)
    end
  end

  defp require_authenticated_user(conn, _opts) do
    if conn.assigns.current_user do
      conn
    else
      conn
      |> Phoenix.Controller.put_flash(:error, "You must be logged in to access this page")
      |> Phoenix.Controller.redirect(to: "/")
      |> halt()
    end
  end

  defp generate_persistent_fingerprint do
    :crypto.strong_rand_bytes(32) |> Base.encode16()
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  # Auth routes
  scope "/auth", RealtimeQaWeb do
    pipe_through :browser

    get "/google", AuthController, :request
    get "/google/callback", AuthController, :callback
    delete "/logout", AuthController, :delete
    post "/logout", AuthController, :delete
  end

  scope "/", RealtimeQaWeb do
    pipe_through :browser

    live_session :public,
      on_mount: [{RealtimeQaWeb.LiveAuth, :default}],
      session: {__MODULE__, :public_session, []} do
        live "/", HomeLive
        live "/room/:code", RoomLive
    end

    live_session :protected,
      on_mount: [{RealtimeQaWeb.LiveAuth, :require_auth}],
      session: {__MODULE__, :protected_session, []} do
        live "/dashboard", DashboardLive
    end

    get "/export/room/:id", ExportController, :export_room_questions
  end

  # Add these functions at the bottom of your Router module
  def public_session(conn) do
    %{
      "user_id" => get_session(conn, :user_id),
      "user_fingerprint" => get_session(conn, :user_fingerprint)
    }
  end

  def protected_session(conn) do
    %{
      "user_id" => get_session(conn, :user_id),
      "user_fingerprint" => get_session(conn, :user_fingerprint)
    }
  end




  # Enable LiveDashboard and Swoosh mailbox preview in development
  if Application.compile_env(:realtime_qa, :dev_routes) do
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: RealtimeQaWeb.Telemetry
      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end
end
