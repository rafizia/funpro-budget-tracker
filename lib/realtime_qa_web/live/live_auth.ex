defmodule RealtimeQaWeb.LiveAuth do
  import Phoenix.LiveView
  import Phoenix.Component
  alias RealtimeQa.Auth

  def on_mount(:default, _params, session, socket) do
    user =
      case session["user_id"] do
        nil -> nil
        user_id -> Auth.get_user(user_id)
      end

    {:cont, assign(socket, :current_user, user)}
  end

  def on_mount(:require_auth, _params, session, socket) do
    user =
      case session["user_id"] do
        nil -> nil
        user_id -> Auth.get_user(user_id)
      end

    if user do
      {:cont, assign(socket, :current_user, user)}
    else
      {:halt,
        socket
        |> put_flash(:error, "You must be logged in.")
        |> redirect(to: "/")
      }
    end
  end
end
