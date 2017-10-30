defmodule StressMan.Supervisor do
  use Supervisor

  def start_link({_worker_count} = state) do
    Supervisor.start_link(__MODULE__, state)
  end

  def init({worker_count}) do
    children = [
      supervisor(Task.Supervisor, [[name: StressMan.TasksSupervisor]]),
      supervisor(Registry, [:unique, :stress_man_process_registry]),
      supervisor(StressMan.WorkerPoolSupervisor, [{worker_count}])
    ]

    supervise(children, [strategy: :one_for_one])
  end
end

defmodule StressMan.WorkerPoolSupervisor do
  use Supervisor

  def start_link({_worker_count} = state) do
    Supervisor.start_link(__MODULE__, state, name: via_tuple())
  end

  defp via_tuple, do: {:via, Registry, {:stress_man_process_registry, "worker_pool_supervisor"}}

  def init({worker_count}) do
    opts = [strategy: :one_for_all,
            max_restart: 5,
            max_time: 3600]

    children = [
      worker(StressMan.Analyser, []),
      worker(StressMan.WorkerPool, [{}]),
      supervisor(StressMan.WorkerSupervisor, [{worker_count}])
    ]

    supervise(children, opts)
  end
end

defmodule StressMan.WorkerSupervisor do
  use Supervisor

  def start_link({_worker_count} = state) do
    Supervisor.start_link(__MODULE__, state, name: via_tuple()  )
  end

  defp via_tuple, do: {:via, Registry, {:stress_man_process_registry, "worker_supervisor"}}

  def worker() do
    Supervisor.which_children(via_tuple()) |> Enum.map(fn {_, pid, _, _} -> pid end)
  end

  def init({worker_count}) do

    children = 1..worker_count
      |> Enum.map( fn n -> worker(StressMan.Worker, [{n}], [id: n, restart: :permanent, function: :start_link]) end )

    opts = [
      strategy: :one_for_one,
      max_restarts: 5,
      max_seconds: 5
    ]

    supervise(children, opts)
  end
end
