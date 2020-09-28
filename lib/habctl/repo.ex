defmodule HabCtl.Repo do
  use Ecto.Repo,
    otp_app: :habctl,
    adapter: Ecto.Adapters.Postgres
end
