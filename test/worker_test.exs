defmodule WorkerPoolTest do
  use ExUnit.Case
  doctest StressMan.Worker

  def client(_url), do: { :success, "200"}

  test "the local client should start worker" do

    StressMan.WorkerPool.schedule(100, "http://example.com", &client/1)
    report = StressMan.Analyser.get()
    assert report.total_count > 0
    assert report.total_time > 100
  end

end
