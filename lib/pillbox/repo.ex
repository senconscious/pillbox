defmodule Pillbox.Repo do
  use Ecto.Repo,
    otp_app: :pillbox,
    adapter: Ecto.Adapters.Postgres
end
