defmodule StressMan.Worker do
  use GenServer
  require Logger
  alias StressMan.Duration

  def start_link({analyser_pid, client} = state) do
    GenServer.start_link(__MODULE__, state)
  end

  def execute(pid, url) do
    GenServer.cast(pid, url)
  end

  def handle_cast(url, {analyser_pid, client}) do
    result = Duration.measure(fn -> client.(url) end)
    Logger.info("worker #{node()}-#{inspect self()}: #{inspect result}")
    StressMan.Analyser.add(analyser_pid, result)
    {:noreply, {analyser_pid, client}}
  end
end

defmodule StressMan.Analyser do
  use GenServer

  def start_link() do
    now = StressMan.Time.now()
    GenServer.start_link(__MODULE__, {0,0,now,now})
  end

  def add(pid, {_duration, {_status, _message} } = record) do
    GenServer.cast(pid, record)
  end

  def get(pid) do
    GenServer.call(pid, :get)
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

  def start_link({analyser_pid, client}) do
     start_link( { StressMan.Worker, :start_link, [{analyser_pid, client}] } )
  end

  def start_worker(pid) do
    Supervisor.start_child(pid, [])
  end

  def start_link(mfa) do
    Supervisor.start_link(__MODULE__, mfa)
  end

  def init({mod, func, args}) do

    worker_opts = [restart: :permanent,
                   function: func]

    children = [
      worker(mod, args, worker_opts)
    ]

    opts = [
      strategy: :simple_one_for_one,
      max_restarts: 5,
      max_seconds: 5
    ]

    supervise(children, opts)
  end
end


defmodule StressMan.WorkerPool do
  use GenServer

  def start_link({worker_supervisor_pid, client} = state) do
    #{:ok, pid} = WorkerSupervisor.start(client)
    GenServer.start_link(__MODULE__, state)
  end

  def schedule(pid, url) do
    GenServer.cast(pid, {:schedule, url})
  end

  def init({worker_supervisor_pid, client}) do
    worker_pids = 1..System.schedulers_online()
      |> Enum.each( fn _n -> WorkerSupervisor.start_worker(worker_supervisor_pid) end )
    {:ok, {worker_supervisor_pid, client}}
  end

  def handle_cast({:schedule, url }, state) do
    # TODO: roundrobin to worker
    {:noreply, state}
  end

end


defmodule StressMan.WorkerPoolSupervisor do
  use Supervisor

  def start_link(:ok) do
    Supervisor.start_link(__MODULE__, :ok)
  end

  def init(:ok) do
    children = [
    ]

    supervise(children, [strategy: :one_for_one])
  end
end

defmodule WTest do
  # StressMan.WorkerSupervisor.start_worker(pid)
  def test() do
    {:ok, a_pid} = StressMan.Analyser.start_link()
    IO.puts "analyser_pid: #{inspect a_pid}"
    {:ok, ws_pid} = StressMan.WorkerSupervisor.start_link({a_pid, &StressMan.HttpClientHandler.get/1})
    ws_pid
  end
end
