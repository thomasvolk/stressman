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
