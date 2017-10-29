defmodule StressMan.Cluster do
  alias StressMan.WorkerPool

  def init_node(name, cookie) do
    Node.start(:"#{name}")
    Node.set_cookie(:"#{cookie}")
  end

  def connect_to_nodes(node_list), do: node_list |> Enum.each(&Node.connect/1)

  def schedule(nodes, duration, url, client) do
    schedule(nodes, duration, url, client, [])
  end

  defp schedule([], _duration, _url, _client, tasks) do
    tasks |> Enum.map(&Task.await(&1, :infinity))
  end

  defp schedule([node|rest], duration, url, client, tasks) do
    new_tasks = [Task.Supervisor.async({StressMan.TasksSupervisor, node}, StressMan.Cluster, :run_task, [duration, url, client]) | tasks]
    schedule(rest, duration, url, client, new_tasks)
  end

  def run_task(duration, url, client) do
    task = Task.async(fn ->
      WorkerPool.schedule(duration, url, client)
    end)
    Task.await(task, :infinity)
  end
end
