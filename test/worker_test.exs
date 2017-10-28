defmodule WorkerPoolTest do
  use ExUnit.Case
  doctest StressMan.Worker

  def client(_url), do: { :success, "200"}

  test "the local client should start worker" do

    worker_count = 4
    StressMan.WorkerPool.start("http://example.com", worker_count, &client/1)

    StressMan.WorkerPool.schedule(100)
  end

end
