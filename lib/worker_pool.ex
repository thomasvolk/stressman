defmodule StressMan.WorkerPool do
    use GenServer

    def start_link({} = state) do
      GenServer.start_link(__MODULE__, state, name: via_tuple())
    end

    defp via_tuple, do: {:via, Registry, {:stress_man_process_registry, "worker_pool"}}

    def schedule(duration, url, client \\ &StressMan.HttpClientHandler.get/1, worker_count \\ System.schedulers_online()) do
      StressMan.WorkerPoolSupervisor.start_link({worker_count})
      now = StressMan.Time.now()
      schedule_next(now, now + duration, url, client)
    end

    defp schedule_next(now, end_time, _url, _client) when now > end_time do
      result = StressMan.Analyser.get()
      StressMan.WorkerPoolSupervisor.stop()
      result
    end

    defp schedule_next(_now, end_time, url, client) do
      GenServer.cast(via_tuple(), {:schedule_next, end_time, url, client})
      schedule_next(StressMan.Time.now(), end_time, url, client)
    end

    def handle_cast({:schedule_next, end_time, url, client}, {} = state) do
      [first_worker_pid|_rest] = StressMan.WorkerSupervisor.worker() |> Enum.shuffle
      StressMan.Worker.open(first_worker_pid, {url, client, end_time})
      {:noreply, state}
    end
end
