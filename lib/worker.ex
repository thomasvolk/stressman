defmodule StressMan.Worker do
  alias StressMan.HttpClientHandler
  use GenServer

  def start_link(http_client) do
    GenServer.start_link(__MODULE__, {http_client})
  end

  def init(state) do
    {:ok, state}
  end

  def handle_cast(url, {http_client}) do
    HttpClientHandler.run(url, http_client)
    {:noreply, {http_client}}
  end
end

defmodule StressMan.WorkerSupervisor do
  use Supervisor

  def start(http_client), do: start_link( { StressMan.Worker, :start_link, [http_client] } )

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

  def start_link(n, url, http_client) when n > 0 do
    {:ok, pid} = WorkerSupervisor.start(http_client)
    worker_pids = 1..System.schedulers_online()
      |> Enum.map( fn _n -> WorkerSupervisor.start_worker(pid) end )
      |> Enum.filter( fn {status, _} -> status == :ok end )
      |> Enum.map( fn {_status, pid} -> pid end )
    schedule_work(n, url, worker_pids)
  end

  def init(:ok) do
  end

  defp schedule_work(0, _url, _) do
  end

  defp schedule_work(n, url, [worker_pid|other_worker_pids]) do
    GenServer.cast(worker_pid, url)
    schedule_work(n - 1, url, other_worker_pids ++ [worker_pid])
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
