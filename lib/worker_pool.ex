defmodule StressMan.WorkerPool do
    use GenServer

    def start(worker_count \\ System.schedulers_online()) do
      StressMan.WorkerPoolSupervisor.start_link({worker_count})
    end

    def start_link({} = state) do
      GenServer.start_link(__MODULE__, state, name: via_tuple())
    end

    defp via_tuple, do: {:via, Registry, {:stress_man_process_registry, "worker_pool"}}

    def schedule(duration, url, client \\ &StressMan.HttpClientHandler.get/1) do
      now = StressMan.Time.now()
      schedule(now, now + duration, url, client)
    end

    def schedule(now, end_time, _url, _client) when now > end_time do
      StressMan.Analyser.reset()
    end

    def schedule(_now, end_time, url, client) do
      GenServer.cast(via_tuple(), {:schedule_next, end_time, url, client})
      schedule(StressMan.Time.now(), end_time, url, client)
    end

    def handle_cast({:schedule_next, end_time, url, client}, {} = state) do
      [first_worker_pid|_rest] = StressMan.WorkerSupervisor.worker() |> Enum.shuffle
      StressMan.Worker.open(first_worker_pid, {url, client, end_time})
      {:noreply, state}
    end
end
