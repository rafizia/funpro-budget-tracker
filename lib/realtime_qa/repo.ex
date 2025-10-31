defmodule RealtimeQa.Repo do
  use Ecto.Repo,
    otp_app: :realtime_qa,
    adapter: Ecto.Adapters.Postgres
end
