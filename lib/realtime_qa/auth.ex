defmodule RealtimeQa.Auth do
  alias RealtimeQa.{Repo, User}

  def find_or_create_user(%{
    email: email,
    name: name,
    google_id: google_id,
    avatar: avatar
  }) do
    case Repo.get_by(User, google_id: google_id) do
      nil ->
        # Create new user
        %User{}
        |> User.changeset(%{
          email: email,
          name: name,
          google_id: google_id,
          avatar: avatar
        })
        |> Repo.insert()

      user ->
        # Update existing user (in case name/email/avatar changed)
        user
        |> User.changeset(%{
          name: name,
          email: email,
          avatar: avatar,
          google_id: google_id
        })
        |> Repo.update()
    end
  end

  def get_user(id), do: Repo.get(User, id)

  def get_user!(id), do: Repo.get!(User, id)
end
