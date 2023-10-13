defmodule Keycat.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      {Phoenix.PubSub, name: Keycat.PubSub},
      KeycatWeb.Presence,
      # Start the Ecto repository
      Keycat.Repo,
      # Start the Telemetry supervisor
      KeycatWeb.Telemetry,
      # Start the Endpoint (http/https)
      KeycatWeb.Endpoint
      # Start a worker by calling: Keycat.Worker.start_link(arg)
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Keycat.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    KeycatWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
