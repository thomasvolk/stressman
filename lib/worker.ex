defmodule StressMan.Worker do
  use GenServer
  require Logger
  alias StressMan.Duration

  def start_link({id} = state) do
    GenServer.start_link(__MODULE__, state, name: via_tuple(id))
  end

  defp via_tuple(id), do: {:via, Registry, {:stress_man_process_registry, "worker#{id}"}}

  def open(pid, {url, client, end_time}) do
    GenServer.cast(pid, {:open, url, client, end_time})
  end

  def init(state) do
    {:ok, state}
  end

  def handle_cast({:open, url, client, end_time}, {id}) do
    if end_time > StressMan.Time.now() do
      result = Duration.measure(fn -> client.(url) end)
      Logger.info("worker#{id} #{node()}-#{inspect self()}: #{inspect result}")
      StressMan.Analyser.add(result)
    end
    {:noreply, {id}}
  end
end

defmodule StressMan.Analyser do
  use GenServer

  def start_link() do
    now = StressMan.Time.now()
    GenServer.start_link(__MODULE__, {0,0,now,now}, name: via_tuple)
  end

  defp via_tuple, do: {:via, Registry, {:stress_man_process_registry, "analyser"}}

  def add({_duration, {_status, _message} } = record) do
    GenServer.cast(via_tuple, {:add, record})
  end

  def get() do
    GenServer.call(via_tuple, :get)
  end

  def init(state) do
    {:ok, state}
  end

  def handle_call(:get, _from, state) do
    {:reply, state, state}
  end

  def handle_cast({:add, { duration, {status, _message} } }, {success_count, error_count, start_time, end_time}) do
    now = StressMan.Time.now()
    new_state = case status do
      :success -> {success_count + 1, error_count, start_time, now}
      _ -> {success_count, error_count + 1, start_time, now}
    end
    {:noreply, new_state}
  end
end

defmodule StressMan.WorkerPool do
    use GenServer

    def start({url, client, worker_count}) do
      StressMan.WorkerPoolSupervisor.start_link({url, client, worker_count})
    end

    def start_link({url, client} = state) do
      GenServer.start_link(__MODULE__, state, name: via_tuple)
    end

    defp via_tuple, do: {:via, Registry, {:stress_man_process_registry, "worker_pool"}}

    def schedule(end_time) do
      GenServer.cast(via_tuple, {:schedule_next, end_time})
    end

    def handle_cast({:schedule_next, end_time}, {url, client} = state) do
      [first_worker_pid|_rest] = StressMan.WorkerSupervisor.worker() |> Enum.shuffle
      StressMan.Worker.open(first_worker_pid, {url, client, end_time})
      {:noreply, state}
    end
end
