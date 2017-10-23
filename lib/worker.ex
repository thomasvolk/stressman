defmodule StressMan.Worker do
  use GenServer
  require Logger
  alias StressMan.Duration

  def start_link({client} = state) do
    GenServer.start_link(__MODULE__, state)
  end

  def execute(url) do
    GenServer.cast({:p, :l, :worker}, url)
  end

  def init(state) do
    :gproc.reg({:p, :l, :worker})
    {:ok, state}
  end

  def handle_cast(url, {client}) do
    result = Duration.measure(fn -> client.(url) end)
    Logger.info("worker #{node()}-#{inspect self()}: #{inspect result}")
    StressMan.Analyser.add(result)
    {:noreply, {client}}
  end
end

defmodule StressMan.Analyser do
  use GenServer

  def start_link() do
    now = StressMan.Time.now()
    GenServer.start_link(__MODULE__, {0,0,now,now})
  end

  def add({_duration, {_status, _message} } = record) do
    GenServer.cast({:via, :gproc, {:p, :l, :analyser}}, record)
  end

  def get() do
    GenServer.call({:via, :gproc, {:p, :l, :analyser}}, :get)
  end

  def init(state) do
    :gproc.reg({:p, :l, :analyser})
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
     start_link( { StressMan.Worker, :start_link, [{client}] } )
  end

  def start_link(mfa) do
    Supervisor.start_link(__MODULE__, mfa)
  end

  def start_worker(pid) do
    Supervisor.start_child(pid, [])
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
