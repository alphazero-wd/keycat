defmodule Keycat.Repo do
  use Ecto.Repo,
    otp_app: :keycat,
    adapter: Ecto.Adapters.Postgres
end
