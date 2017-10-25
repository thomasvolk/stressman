defmodule StressMan.Supervisor do
  use Supervisor

  def start_link(:ok) do
    Supervisor.start_link(__MODULE__, :ok)
  end

  def init(:ok) do
    children = [
      supervisor(Task.Supervisor, [[name: StressMan.TasksSupervisor]]),
      supervisor(Registry, [:unique, :stress_man_process_registry])
    ]

    supervise(children, [strategy: :one_for_one])
  end
end
