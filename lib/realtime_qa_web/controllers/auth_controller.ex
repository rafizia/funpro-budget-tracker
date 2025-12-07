defmodule RealtimeQaWeb.AuthController do
  use RealtimeQaWeb, :controller

  plug Ueberauth, providers: [:google]

  alias RealtimeQa.Auth

  # GET /auth/google
  def request(conn, _params) do
    case get_session(conn, :user_id) do
      nil ->
        conn

      user_id ->
        user = Auth.get_user(user_id)
        conn
        |> put_flash(:info, "You're already logged in as #{user.name}")
        |> redirect(to: ~p"/dashboard")
        |> halt()
    end
  end

  # SUCCESS callback
  def callback(%{assigns: %{ueberauth_auth: auth}} = conn, _params) do
    name = auth.info.name ||
           get_in(auth.extra.raw_info, ["user", "name"]) ||
           get_in(auth.extra.raw_info, ["name"]) ||
           get_in(auth.extra.raw_info, [:name]) ||
           extract_name_from_email(auth.info.email)

    avatar = auth.info.image ||
             get_in(auth.extra.raw_info, ["user", "picture"]) ||
             get_in(auth.extra.raw_info, ["picture"]) ||
             get_in(auth.extra.raw_info, [:picture]) ||
             generate_avatar_url(auth.info.email)

    user_params = %{
      email: auth.info.email,
      name: name,
      google_id: auth.uid,
      avatar: avatar
    }

    case Auth.find_or_create_user(user_params) do
      {:ok, user} ->
        conn
        |> put_session(:user_id, user.id)
        |> put_flash(:info, "Welcome, #{user.name}!")
        |> redirect(to: ~p"/dashboard")

      {:error, _changeset} ->
        conn
        |> put_flash(:error, "Failed to authenticate with Google")
        |> redirect(to: ~p"/")
    end
  end

  # FAILURE callback
  def callback(%{assigns: %{ueberauth_failure: _fails}} = conn, _params) do
    conn
    |> put_flash(:error, "Failed to authenticate with Google. Please try again.")
    |> redirect(to: "/")
  end

  # Catch-all for unexpected callback scenarios
  def callback(conn, _params) do
    conn
    |> put_flash(:error, "An unexpected error occurred during authentication.")
    |> redirect(to: "/")
  end

  # /auth/logout
  def delete(conn, _params) do
    conn
    |> configure_session(drop: true)
    |> put_flash(:info, "Logged out successfully")
    |> redirect(to: "/")
  end

  # Helper functions
  defp extract_name_from_email(email) do
    email
    |> String.split("@")
    |> List.first()
    |> String.split(".")
    |> Enum.map(&String.capitalize/1)
    |> Enum.join(" ")
  end

  defp generate_avatar_url(email) do
    hash = :crypto.hash(:md5, String.downcase(email))
           |> Base.encode16(case: :lower)
    "https://www.gravatar.com/avatar/#{hash}?d=identicon&s=200"
  end
end
