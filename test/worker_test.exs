defmodule WorkerPoolTest do
  use ExUnit.Case
  doctest StressMan.Worker

  def client(_url), do: { :success, "200"}

  test "the local client should start worker" do

    StressMan.WorkerPoolSupervisor.start_link({&client/1})

    GenServer.cast({:via, :gproc, {:p, :l, :worker}}, "http://example.com")
  end

end
