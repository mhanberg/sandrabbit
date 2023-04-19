defmodule Sandrabbit.Repo do
  use Ecto.Repo,
    otp_app: :sandrabbit,
    adapter: Ecto.Adapters.Postgres
end
