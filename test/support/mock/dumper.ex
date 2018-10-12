defmodule Pedets.Mock.Dumper do
  @moduledoc """
  This module is a Dumper mock.
  It can be used in place of it for testing.
  It will respond with given function's response when called,
  and will save any received calls for further inspection.
  Example of use:
  ```
  # Suppose we have a mockable module
  defmodule A do
    def dump(opts) do
      opts[:dump_fun].(:table, 'filename')
    end
  end
  # Production request would be like this
  A.dump(dump_fun: &Pedets.Dumper.dump/2)
  # To mock it on test first spawn a fresh mock
  alias Pedets.Mock.Dumper, as: M
  {:ok, mock} = M.spawn()
  # Then get the mocked function
  # and use it from your test request
  A.dump(dump_fun: M.get(mock))
  # The mock agent will collect any activity for this mock
  M.get_report(mock)
  ```
  """

  defmodule D do
    @moduledoc false
    defstruct fun: nil, logs: []
  end

  @doc """
  This will spawn a new mock with given fun.
  If no function is given, `Dumper.ok/2` is used.
  It returns {:ok, pid}.
  """
  def spawn(fun) when is_function(fun) do
    Agent.start_link(fn -> %D{fun: fun} end)
  end
  def spawn, do: __MODULE__.spawn(&ok/2)

  @doc """
  This returns current state of the mock given its pid.
  """
  def get_report(pid), do: Agent.get(pid, & &1)

  @doc """
  Returns the number of log entries for given mock pid.
  """
  def count(pid) do
    %D{logs: l} = get_report(pid)
    Enum.count(l)
  end

  @doc "Simple :ok response"
  def ok(_, _), do: :ok

  @doc """
  This implements the mock for `Dumper.dump/2`.
  It receives the pid of the previously spawned mock.
  It returns a function with the same signature, so that it can be
  used in place of the original, but it will use the mock's function
  to get the response, and it will save the operation in the internal log.
  """
  def get(pid) do
    fn name, path ->
      res = get_response(pid, name, path)
      log(pid, %{name: name, path: path, response: res})
      res
    end
  end

  defp get_response(pid, name, path) do
    pid
    |> Agent.get(fn %D{} = d -> d end)
    |> Map.get(:fun)
    |> apply([name, path])
  end

  defp log(pid, data) do
    Agent.update(pid, fn %D{} = d ->
      %D{d | logs: [data | d.logs]}
    end)
  end
end
