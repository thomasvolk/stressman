defmodule StressMan.Cluster do
  def init_node(name, cookie) do
    Node.start(:"#{name}")
    Node.set_cookie(:"#{cookie}")
  end

  def connect_to_nodes(node_list), do: node_list |> Enum.each(&Node.connect/1)

  def schedule(nodes, task, scheduler) do
    schedule(nodes, task, scheduler, [])
  end

  defp schedule([], _task, _scheduler, tasks) do
    tasks |> Enum.map(&Task.await(&1, :infinity))
  end

  defp schedule([node|rest], task, scheduler, tasks) do
    new_tasks = [Task.Supervisor.async({StressMan.TasksSupervisor, node}, StressMan.Cluster, :run_task, [task, scheduler]) | tasks]
    schedule(rest, task, scheduler, new_tasks)
  end

  def run_task(task, scheduler) do
    scheduler.(task)
  end
end
