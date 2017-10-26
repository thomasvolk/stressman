defmodule WorkerPoolTest do
  use ExUnit.Case
  doctest StressMan.Worker

  def client(_url), do: { :success, "200"}

  test "the local client should start worker" do

    worker_count = 4 # System.schedulers_online()
    StressMan.WorkerPool.start({"http://example.com", &client/1, worker_count})

    StressMan.WorkerPool.schedule(StressMan.Time.now() + 100)
  end

end
