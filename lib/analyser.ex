
defmodule StressMan.Analyser do
  use GenServer

  def start_link() do
    GenServer.start_link(__MODULE__, initial_state(), name: via_tuple())
  end

  defp via_tuple, do: {:via, Registry, {:stress_man_process_registry, "analyser"}}

  defp initial_state() do
    now = StressMan.Time.now()
    {0,0,now,now}
  end

  def add({_duration, {_status, _message} } = record) do
    GenServer.cast(via_tuple(), {:add, record})
  end

  def get() do
    GenServer.call(via_tuple(), :get)
  end

  def reset() do
    GenServer.call(via_tuple(), :reset)
  end

  def init(state) do
    {:ok, state}
  end

  defp result({success_count, error_count, start_time, end_time}) do
    {success_count, error_count, end_time - start_time}
  end

  def handle_call(:get, _from, state) do
    {:reply, result(state) , state}
  end

  def handle_call(:reset, _from, state) do
    {:reply, result(state), initial_state()}
  end

  def handle_cast({:add, { _duration, {status, _message} } }, {success_count, error_count, start_time, _end_time}) do
    now = StressMan.Time.now()
    new_state = case status do
      :success -> {success_count + 1, error_count, start_time, now}
      _ -> {success_count, error_count + 1, start_time, now}
    end
    {:noreply, new_state}
  end
end
