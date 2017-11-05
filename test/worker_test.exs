defmodule WorkerPoolTest do
  use ExUnit.Case
  doctest StressMan.Worker

  def client(_url), do: { :success, "200"}

  test "the local client should start worker" do

    {success_count, error_count, duration} = StressMan.WorkerPool.schedule(100, "http://example.com", &client/1, 4)
    assert success_count > 0
    assert duration > 100
    assert error_count == 0
  end

end
