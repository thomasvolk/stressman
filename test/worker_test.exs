defmodule WorkerPoolTest do
  use ExUnit.Case
  doctest StressMan.Worker

  def client(_url), do: { :success, "200"}

  test "the local client should start worker" do
    {:ok, a_pid} = StressMan.Analyser.start_link()
    {:ok, ws_pid} = StressMan.WorkerSupervisor.start_link({&client/1})

    1..System.schedulers_online()
      |> Enum.each( fn _n -> StressMan.WorkerSupervisor.start_worker(ws_pid) end )

      GenServer.cast({:via, :gproc, {:p, :l, :worker}}, "http://example.com")
  end

end
