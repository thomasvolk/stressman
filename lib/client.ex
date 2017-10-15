defmodule StressMan.RemoteClient do
  alias StressMan.TasksSupervisor
  require Logger

  def start_worker(n, nodes, url, http_client) when n > 0 do
    start_worker(n, nodes, url, http_client, []) |> List.flatten
  end

  defp start_worker(n, [node|rest], url, http_client, tasks) when n > 0 do
    new_tasks = [Task.Supervisor.async({TasksSupervisor, node}, StressMan.NodeTask, :start, [n, url, http_client]) | tasks]
    start_worker(n, rest, url, http_client, new_tasks)
  end

  defp start_worker(_n, [], _url, _http_client, tasks) do
    tasks |> Enum.map(&Task.await(&1, :infinity))
  end
end

defmodule StressMan.NodeTask do
  def start(n, url, http_client \\ &HTTPoison.get/1) do
     StressMan.LocalClient.start_worker(n, url, http_client)
  end
end

defmodule StressMan.LocalClient do
  require Logger
  def start_worker(n, url, http_client) when n > 0 do
    worker = fn -> StressMan.Worker.start(url, http_client) end
    1..n |> Enum.map( fn _ -> Task.async(worker) end ) |> Enum.map(&Task.await(&1, :infinity))
  end
end
