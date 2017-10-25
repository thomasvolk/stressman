defmodule WorkerPoolTest do
  use ExUnit.Case
  doctest StressMan.Worker

  def client(_url), do: { :success, "200"}

  test "the local client should start worker" do

    StressMan.WorkerPoolSupervisor.start_link({&client/1})

    StressMan.WorkerPoolSupervisor.schedule("http://example.com")
    StressMan.WorkerPoolSupervisor.schedule("http://example.com")
    StressMan.WorkerPoolSupervisor.schedule("http://example.com")
    StressMan.WorkerPoolSupervisor.schedule("http://example.com")

    #:timer.sleep 2000
  end

end
