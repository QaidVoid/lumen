defmodule Lumen.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      LumenWeb.Telemetry,
      Lumen.Repo,
      {DNSCluster, query: Application.get_env(:lumen, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: Lumen.PubSub},
      {Oban, Application.fetch_env!(:lumen, Oban)},
      # Start a worker by calling: Lumen.Worker.start_link(arg)
      # {Lumen.Worker, arg},
      # Start to serve requests, typically the last entry
      LumenWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Lumen.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    LumenWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
