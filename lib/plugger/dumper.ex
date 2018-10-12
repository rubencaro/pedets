defmodule Pedets.Dumper do
  @moduledoc false
  use GenServer

  defmodule D do
    @moduledoc false
    defstruct name: :busytable,
              path: "tmp/dump_busytable",
              timeout: 5000,
              dump_fun: &Dumper.dump/2
  end

  def start_link(opts) do
    d = apply_defaults(opts)
    GenServer.start_link(__MODULE__, d, [])
  end

  defp apply_defaults(given) do
    %D{}
    |> Map.merge(given |> Enum.into(%{}))
  end

  def init(%D{} = opts), do: {:ok, opts, opts.timeout}

  def handle_info(:timeout, %D{} = opts) do
    opts.dump_fun.(opts.name, opts.path)
    {:noreply, opts, opts.timeout}
  end

  def dump(name, path) do
    :ets.tab2file(name, path |> to_charlist())
  end
end
