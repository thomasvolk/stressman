defmodule StressMan.WorkerPool do
    use GenServer

    def start_link({} = state) do
      GenServer.start_link(__MODULE__, state, name: via_tuple())
    end

    defp via_tuple, do: {:via, Registry, {:stress_man_process_registry, "worker_pool"}}

    def schedule_next(end_time, url, client) do
      GenServer.cast(via_tuple(), {:schedule_next, end_time, url, client})
    end

    def handle_cast({:schedule_next, end_time, url, client}, {} = state) do
      [first_worker_pid|_rest] = StressMan.WorkerSupervisor.worker() |> Enum.shuffle
      StressMan.Worker.open(first_worker_pid, {url, client, end_time})
      {:noreply, state}
    end
end
