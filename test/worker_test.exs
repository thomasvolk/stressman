defmodule WorkerPoolTest do
  use ExUnit.Case
  doctest StressMan.Worker
  alias StressMan.Scheduler.ScheduleTask

  def client(_url), do: { :success, "200"}

  test "the local client should start worker" do

    task = %ScheduleTask{duration: 100, url: "http://example.com", worker_count: 4, client: &client/1}
    {success_count, error_count, duration} = StressMan.Scheduler.schedule(task)
    assert success_count > 0
    assert duration > 100
    assert error_count == 0
  end

end
