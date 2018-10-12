alias Pedets.Web.{MetricsExporter, MetricsInstrumenter, Router}
alias Plug.Adapters.Cowboy2

defmodule Pedets.Application do
  @moduledoc false

  use Application

  def start(_type, _args) do
    MetricsExporter.setup()
    MetricsInstrumenter.setup()

    children = [
      Cowboy2.child_spec(
        scheme: :http,
        plug: Router,
        options: [port: 4001]
      ),
      {Pedets.ETSHolder, :busytable}
    ]

    opts = [strategy: :one_for_one, name: Pedets.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
