defmodule WorkerPoolTest do
  use ExUnit.Case
  doctest StressMan.WorkerPool
  alias StressMan.WorkerPool
  alias StressMan.Report

  def client(_url), do: { :success, "200"}

  test "the local client should start worker" do
    {:ok, a_pid} = StressMan.Analyser.start_link()
    IO.puts "analyser_pid: #{inspect a_pid}"
    {:ok, ws_pid} = StressMan.WorkerSupervisor.start_link({a_pid, &client/1})
    IO.puts "worker_supervisor_pid: #{inspect ws_pid}"
    {:ok, wp_pid} = StressMan.WorkerPool.start_link(ws_pid)

    StressMan.WorkerPool.schedule(wp_pid, "http://example.com")
  end

end
