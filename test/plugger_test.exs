defmodule PedetsTest do
  use ExUnit.Case
  use Plug.Test

  @opts Pedets.Web.Router.init([])

  test "greets the world" do
    assert Pedets.hello() == :world
  end

  test "returns hello world" do
    # Create a test connection
    conn = conn(:get, "/hello")

    # Invoke the plug
    conn = Pedets.Web.Router.call(conn, @opts)

    # Assert the response and status
    assert conn.state == :sent
    assert conn.status == 200
    assert conn.resp_body == "world"
  end

  test "returns some metrics" do
    # Create a test connection
    conn = conn(:get, "/metrics")

    # Invoke the plug
    conn = Pedets.Web.Router.call(conn, @opts)

    # Assert the response and status
    assert conn.state == :sent
    assert conn.status == 200

    # Assert contains at least 'http_requests_total' metric
    assert String.contains?(conn.resp_body, "http_requests_total")
  end
end
