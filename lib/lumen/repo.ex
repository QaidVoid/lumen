defmodule Lumen.Repo do
  use Ecto.Repo,
    otp_app: :lumen,
    adapter: Ecto.Adapters.Postgres
end
