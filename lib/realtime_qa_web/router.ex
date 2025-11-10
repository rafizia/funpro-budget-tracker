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
  end

  defp put_user_fingerprint(conn, _opts) do
    case conn.req_cookies["user_fingerprint"] do
      nil ->
        # Generate fingerprint baru
        fingerprint = generate_persistent_fingerprint()

        conn
        |> put_resp_cookie("user_fingerprint", fingerprint,
            max_age: 365 * 24 * 60 * 60,  # 1 tahun
            http_only: true,
            same_site: "Lax"
          )
        |> put_session(:user_fingerprint, fingerprint)

      fingerprint ->
        # Gunakan fingerprint yang sudah ada
        put_session(conn, :user_fingerprint, fingerprint)
    end
  end

  defp generate_persistent_fingerprint do
    :crypto.strong_rand_bytes(32) |> Base.encode16()
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", RealtimeQaWeb do
    pipe_through :browser

    live "/", RoomLive
    live "/dashboard", DashboardLive
    live "/room/:code", RoomLive
  end

  # Other scopes may use custom stacks.
  # scope "/api", RealtimeQaWeb do
  #   pipe_through :api
  # end

  # Enable LiveDashboard and Swoosh mailbox preview in development
  if Application.compile_env(:realtime_qa, :dev_routes) do
    # If you want to use the LiveDashboard in production, you should put
    # it behind authentication and allow only admins to access it.
    # If your application does not have an admins-only section yet,
    # you can use Plug.BasicAuth to set up some basic authentication
    # as long as you are also using SSL (which you should anyway).
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: RealtimeQaWeb.Telemetry
      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end
end
