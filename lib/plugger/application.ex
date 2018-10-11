defmodule Pedets.Application do
  @moduledoc false

  use Application

  def start(_type, _args) do

    Pedets.Web.MetricsExporter.setup()
    Pedets.Web.MetricsInstrumenter.setup()

    children = [
      Plug.Adapters.Cowboy2.child_spec(
        scheme: :http,
        plug: Pedets.Web.Router,
        options: [port: 4001]
      )
    ]

    opts = [strategy: :one_for_one, name: Pedets.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
