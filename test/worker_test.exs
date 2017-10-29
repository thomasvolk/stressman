defmodule WorkerPoolTest do
  use ExUnit.Case
  doctest StressMan.Worker

  def client(_url), do: { :success, "200"}

  test "the local client should start worker" do

    #worker_count = 4
    #StressMan.WorkerPool.start(worker_count)

    StressMan.WorkerPool.schedule(100, "http://example.com", &client/1)
  end

end
