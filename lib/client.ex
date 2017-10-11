defmodule StressMan.Client do
  alias StressMan.TasksSupervisor
  require Logger

  def round_robin([first_item|rest]) do
    {first_item, rest ++ [first_item]}
  end

  def run(n, name, node_list, url, http_client, cookie) when n > 0 do
    Logger.info("start client: #{name}")
    Node.start(name)
    Node.set_cookie(:"#{cookie}")
    node_list |> Enum.each(&Node.connect/1)
    start_worker(n, round_robin(Node.list()), url, http_client, [])
  end

  defp start_worker(n, {worker, worker_nodes}, url, http_client, tasks) when n > 0 do
    new_tasks = [Task.Supervisor.async({TasksSupervisor, worker}, StressMan.Worker, :start, [url, http_client]) | tasks]
    start_worker(n - 1, round_robin(worker_nodes), url, http_client, new_tasks)
  end

  defp start_worker(_n, _, _url, _http_client, tasks) do
    tasks |> Enum.map(&Task.await(&1, :infinity))
  end
end
