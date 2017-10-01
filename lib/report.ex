defmodule Stress.Report do
  def generate(results, output) do
    total_cnt = Enum.count(results)
    error_cnt = results |> Enum.filter( fn { status, _} -> status == :error end ) |> Enum.count
    success_cnt = total_cnt - error_cnt


    average = results |> Enum.map( fn {_status, {_code, ms}} -> ms end) |> average

    output.("""
    total:         #{total_cnt}
    success:       #{success_cnt}
    errors:        #{error_cnt}

    average (ms):  #{average}
    """)
  end

  def average(values) do
    Enum.sum(values) / Enum.count(values)
  end

end
