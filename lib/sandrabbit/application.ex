defmodule Sandrabbit.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      # Start the Telemetry supervisor
      SandrabbitWeb.Telemetry,
      # Start the Ecto repository
      Sandrabbit.Repo,
      # Start the PubSub system
      Supervisor.child_spec({Cachex, name: :message_cache}, id: :message_cache),
      Sandrabbit.Consumer,
      {Phoenix.PubSub, name: Sandrabbit.PubSub},
      # Start Finch
      {Finch, name: Sandrabbit.Finch},
      # Start the Endpoint (http/https)
      SandrabbitWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Sandrabbit.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    SandrabbitWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
