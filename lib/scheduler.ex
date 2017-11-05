defmodule StressMan.Scheduler do
  alias StressMan.WorkerPoolSupervisor
  alias StressMan.WorkerPool
  alias StressMan.Time
  alias StressMan.HttpClientHandler
  alias StressMan.Analyser

  defmodule ScheduleTask do
    defstruct duration: 1000, url: nil, worker_count: System.schedulers_online(), client: &HttpClientHandler.get/1
  end

  def schedule(%ScheduleTask{duration: duration, url: url, worker_count: worker_count, client: client}) do
    WorkerPoolSupervisor.start_link({worker_count})
    now = StressMan.Time.now()
    schedule_next(now, now + duration, url, client)
  end

  defp schedule_next(now, end_time, _url, _client) when now > end_time do
    result = Analyser.get()
    WorkerPoolSupervisor.stop()
    result
  end

  defp schedule_next(_now, end_time, url, client) do
    WorkerPool.schedule_next(end_time, url, client)
    schedule_next(Time.now(), end_time, url, client)
  end
end
