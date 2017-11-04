defmodule StressMan.Cluster do
  def init_node(name, cookie) do
    Node.start(:"#{name}")
    Node.set_cookie(:"#{cookie}")
  end

  def connect_to_nodes(node_list), do: node_list |> Enum.each(&Node.connect/1)

  def schedule(nodes, function) do
    schedule(nodes, function, [])
  end

  defp schedule([], _function, tasks) do
    tasks |> Enum.map(&Task.await(&1, :infinity))
  end

  defp schedule([node|rest], function, tasks) do
    new_tasks = [Task.Supervisor.async({StressMan.TasksSupervisor, node}, StressMan.Cluster, :run_task, [function]) | tasks]
    schedule(rest, function, new_tasks)
  end

  def run_task(function) do
    function.()
  end
end
