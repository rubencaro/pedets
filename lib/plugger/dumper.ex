defmodule Pedets.Dumper do
  @moduledoc false

  def dump(name, path) do
    :ets.tab2file(name, path |> to_charlist())
  end
end
