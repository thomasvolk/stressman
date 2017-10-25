defmodule StressMan.Worker do
  use GenServer
  require Logger
  alias StressMan.Duration

  def start_link({id, client} = state) do
    GenServer.start_link(__MODULE__, state, name: via_tuple(id))
  end

  defp via_tuple(id), do: {:via, Registry, {:stress_man_process_registry, "worker#{id}"}}

  def open(id, url) do
    GenServer.cast(via_tuple(id), url)
  end

  def init(state) do
    {:ok, state}
  end

  def handle_cast(url, {id, client}) do
    result = Duration.measure(fn -> client.(url) end)
    Logger.info("worker#{id} #{node()}-#{inspect self()}: #{inspect result}")
    StressMan.Analyser.add(result)
    {:noreply, {id, client}}
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
    GenServer.cast(via_tuple, record)
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

  def handle_cast({duration, {status, _message} }, {success_count, error_count, start_time, end_time}) do
    now = StressMan.Time.now()
    new_state = case status do
      :success -> {success_count + 1, error_count, start_time, now}
      _ -> {success_count, error_count + 1, start_time, now}
    end
    {:noreply, new_state}
  end
end

defmodule StressMan.WorkerSupervisor do
  use Supervisor

  def start_link({client}) do
    Supervisor.start_link(__MODULE__, {client}, name: via_tuple)
  end

  defp via_tuple, do: {:via, Registry, {:stress_man_process_registry, "worker_supervisor"}}

  def schedule(url) do
    [first_worker_pid|_rest] = Supervisor.which_children(via_tuple) |> Enum.map(fn {_, pid, _, _} -> pid end) |> Enum.shuffle
    GenServer.cast(first_worker_pid, url)
  end

  def init({client}) do

    children = 1..System.schedulers_online()
      |> Enum.map( fn n -> worker(StressMan.Worker, [{n, client}], [id: n, restart: :permanent, function: :start_link]) end )

    opts = [
      strategy: :one_for_one,
      max_restarts: 5,
      max_seconds: 5
    ]

    supervise(children, opts)
  end
end

defmodule StressMan.WorkerPoolSupervisor do
  use Supervisor

  def start_link({client}) do
    Supervisor.start_link(__MODULE__, {client})
  end

  def schedule(url), do: StressMan.WorkerSupervisor.schedule(url)

  def init({client}) do
    opts = [strategy: :one_for_all,
            max_restart: 5,
            max_time: 3600]

    children = [
      worker(StressMan.Analyser, []),
      supervisor(StressMan.WorkerSupervisor, [{client}])
    ]

    supervise(children, opts)
  end
end
