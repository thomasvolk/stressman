defmodule StressMan.Client do
  alias StressMan.TasksSupervisor
  alias StressMan.RoundRobin
  require Logger

  def start_local_worker(n, url, http_client) when n > 0 do
    worker = fn -> StressMan.Worker.start(url, http_client) end
    1..n |> Enum.map( fn _ -> Task.async(worker) end ) |> Enum.map(&Task.await(&1, :infinity))
  end

  def start_remote_worker(n, nodes, url, http_client) when n > 0 do
    start_remote_worker(n, RoundRobin.next(nodes), url, http_client, [])
  end

  defp start_remote_worker(n, {node, nodes}, url, http_client, tasks) when n > 0 do
    new_tasks = [Task.Supervisor.async({TasksSupervisor, node}, StressMan.Worker, :start, [url, http_client]) | tasks]
    start_remote_worker(n - 1, RoundRobin.next(nodes), url, http_client, new_tasks)
  end

  defp start_remote_worker(_n, _, _url, _http_client, tasks) do
    tasks |> Enum.map(&Task.await(&1, :infinity))
  end
end
