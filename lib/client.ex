defmodule StressMan.Client do
  alias StressMan.TasksSupervisor
  alias StressMan.RoundRobin
  require Logger

  def run(n, nodes, url, http_client) when n > 0 do
    start_node(n, RoundRobin.next(nodes), url, http_client, [])
  end

  def start_worker(n, url, http_client) when n > 0 do
    worker = fn -> StressMan.Worker.start(url, http_client) end
    1..n |> Enum.map( fn _ -> Task.async(worker) end ) |> Enum.map(&Task.await(&1, :infinity))
  end

  defp start_node(n, {node, nodes}, url, http_client, tasks) when n > 0 do
    new_tasks = [Task.Supervisor.async({TasksSupervisor, node}, StressMan.Worker, :start, [url, http_client]) | tasks]
    start_node(n - 1, RoundRobin.next(nodes), url, http_client, new_tasks)
  end

  defp start_node(_n, _, _url, _http_client, tasks) do
    tasks |> Enum.map(&Task.await(&1, :infinity))
  end
end
