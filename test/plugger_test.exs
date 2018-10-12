alias Pedets.Web.Router
alias Pedets.{Holder, Dumper}

defmodule PedetsTest do
  @moduledoc false
  use ExUnit.Case
  use Plug.Test

  @opts Router.init([])

  setup_all do
    File.rm_rf("tmp")
    :ok = File.mkdir("tmp")
    :ok
  end

  test "greets the world" do
    assert Pedets.hello() == :world
  end

  test "returns hello world" do
    # Create a test connection
    conn = conn(:get, "/hello")

    # Invoke the plug
    conn = Router.call(conn, @opts)

    # Assert the response and status
    assert conn.state == :sent
    assert conn.status == 200
    assert conn.resp_body == "world"
  end

  test "returns some metrics" do
    # Create a test connection
    conn = conn(:get, "/metrics")

    # Invoke the plug
    conn = Router.call(conn, @opts)

    # Assert the response and status
    assert conn.state == :sent
    assert conn.status == 200

    # Assert contains at least 'http_requests_total' metric
    assert String.contains?(conn.resp_body, "http_requests_total")
  end

  test "responds 404 to not found" do
    # Create a test connection
    conn = conn(:get, "/any")

    # Invoke the plug
    conn = Router.call(conn, @opts)

    # Assert the response and status
    assert conn.state == :sent
    assert conn.status == 404
  end

  test "start code does not crash" do
    {:error, {:already_started, _pid}} = Pedets.Application.start(:normal, [])
  end

  test "Holder starts" do
    {:ok, _} = Holder.start_link(:any)
  end

  test "Dumper starts" do
    {:ok, _} = Dumper.start_link(:any)
  end

  test "Dumper dumps a valid dump" do
    name = System.system_time(:nanosecond) |> to_string() |> String.to_atom()
    path = "tmp/dump_#{name |> to_string()}"
    data = {:hey, :you}

    {:ok, holder} = Holder.start_link(name)
    assert :ets.insert(name, data)
    :ok = Dumper.dump(name, path)
    assert File.exists?(path)
    :ok = GenServer.stop(holder)
    {:ok, _} = :ets.file2tab(path |> to_charlist(), verify: true)
    assert ^data = name |> :ets.lookup(:hey) |> hd()
  end

  test "Dumper D struct has nice defaults" do
    %Pedets.Dumper.D{}
    |> Map.from_struct()
    |> Enum.all?(fn {_, v} -> assert !is_nil(v) end)
  end
end
