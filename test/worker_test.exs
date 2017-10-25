defmodule WorkerPoolTest do
  use ExUnit.Case
  doctest StressMan.Worker

  def client(_url), do: { :success, "200"}

  test "the local client should start worker" do

    worker_count = 4 # System.schedulers_online()
    StressMan.WorkerPoolSupervisor.start_link({"http://example.com", &client/1, worker_count})

    StressMan.WorkerPool.schedule_next()
    StressMan.WorkerPool.schedule_next()
    StressMan.WorkerPool.schedule_next()
    StressMan.WorkerPool.schedule_next()
    StressMan.WorkerPool.schedule_next()

    #:timer.sleep 2000
  end

end
