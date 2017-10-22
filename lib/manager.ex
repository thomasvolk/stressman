defmodule StressMan.Manager do
  #alias StressMan.TasksSupervisor

  def start(n, url, http_client, nodes) when n > 0 do
    start_worker(n, nodes, url, http_client, []) |> List.flatten
  end

  def start(n, url, http_client) when n > 0 do
    start_worker(n, [node()], url, http_client, []) |> List.flatten
  end

  defp start_worker(n, [_node|_rest], _url, _http_client, _tasks) when n > 0 do
    #new_tasks = [Task.Supervisor.async({TasksSupervisor, node}, StressMan.WorkerPool, :start, [n, url, http_client]) | tasks]
    #start_worker(n, rest, url, http_client, new_tasks)
  end

  defp start_worker(_n, [], _url, _http_client, tasks) do
    tasks |> Enum.map(&Task.await(&1, :infinity))
  end
end
