defmodule Stress.Report do
  def generate(results, total_time_ms, output) do
    total_cnt = Enum.count(results)
    success = results |> Enum.filter( fn { status, _} -> status != :error end )
    success_cnt = Enum.count(success)
    error_cnt = total_cnt - success_cnt


    average = success |> Enum.map( fn {_status, {_code, ms}} -> ms end) |> average

    output.("""
    total time (ms)       #{total_time_ms}

    total:                #{total_cnt}
    success:              #{success_cnt}
    errors:               #{error_cnt}

    success calls
      average (ms):       #{average}
      throughput (req/s): #{success_cnt / (total_time_ms / 1000)}
    """)
  end

  def average([]), do: nil

  def average(values), do: Enum.sum(values) / Enum.count(values)

end
