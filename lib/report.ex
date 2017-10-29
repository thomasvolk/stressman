defmodule StressMan.Report do
  def create([head|rest]) do
    create(rest, head)
  end

  def create({success_count, error_count, duration}) do
    total_count = success_count + error_count
    average_request_duration = case total_count do
      0 -> 0
      _ -> duration / success_count
    end
    throughput = case duration do
      0 -> 0
      _ -> success_count / duration
    end
    %{
      total_count: total_count,
      duration: duration,
      success_count: success_count,
      error_count: error_count,
      average_request_duration: average_request_duration,
      throughput: throughput
    }
  end

  def create([], data), do: create(data)

  def create([{next_success_count, next_error_count, next_duration}|rest],
              {success_count, error_count, duration}) do
    new_duration = if next_duration > duration do
      next_duration
    else
      duration
    end
    data = { success_count + next_success_count, error_count + next_error_count, new_duration}
    create(rest, data)
  end

  def print(report, output) do
    output.("""
    duration (ms)         #{report.duration}

    total:                #{report.total_count}
    success:              #{report.success_count}
    errors:               #{report.error_count}

    success calls
      average request duration (ms):  #{report.average_request_duration}
      throughput (req/s):             #{report.throughput * 1000}
    """)
  end
end
