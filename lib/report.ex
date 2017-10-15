defmodule StressMan.Report do
  def generate({total_time_ms, results}) do
    total_cnt = Enum.count(results)
    success = results |> Enum.filter( fn { status, _} -> status != :error end )
    success_cnt = Enum.count(success)
    error_cnt = total_cnt - success_cnt
    average = success |> Enum.map( fn {_status, {_code, ms}} -> ms end) |> average
    throughput = success_cnt / (total_time_ms / 1000)
    %{
      total_cnt: total_cnt,
      total_time_ms: total_time_ms,
      success_cnt: success_cnt,
      error_cnt: error_cnt,
      average: average,
      throughput: throughput
    }
  end

  def average([]), do: nil

  def average(values), do: Enum.sum(values) / Enum.count(values)

end
