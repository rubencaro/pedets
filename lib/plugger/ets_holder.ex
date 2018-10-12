defmodule Pedets.ETSHolder do
  @moduledoc false
  use GenServer

  def start_link(name), do: GenServer.start_link(__MODULE__, name, [])

  def init(name) do
    :ets.new(name, [:named_table, :public])
    {:ok, :ok}
  end
end
