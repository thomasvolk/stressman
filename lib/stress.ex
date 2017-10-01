defmodule Stress do
  alias Stress.Report, as: Report

  def main(args), do: System.halt(main(args, &IO.puts/1, &HTTPoison.get/1))

  def main(args, output, http_client) do
    args |> parse_args |> run(output, http_client)
  end

  defp parse_args(args) do
    OptionParser.parse(args, aliases: [n: :requests],
                              strict: [requests: :integer])
  end

  def usage(output) do
    output.("""
    Stress 0.1
    Copyright 2017 Thomas Volk
    usage:
      simple:
        stress --requests <REQUESTS> <URL>
      client:
        stress --client <CLIENT_NAME_A@HOST> --nodes <SERVER_NAME_A@HOST>,<SERVER_NAME_B@HOST>,... --requests <REQUESTS> <URL>
      server:
        stress --server <SERVER_NAME_A@HOST>
    """)
  end

  defp run(options, output, http_client) do
    case options do
      {[requests: n], [url], []} ->
        simple_run(n, url, http_client, output)
        0
      _ ->
        output.("ERROR: wrong parameter!")
        usage(output)
        1
    end
  end

  def simple_run(n, url, http_client, output) when n > 0 do
    worker = fn -> Stress.Worker.start(url, http_client) end
    results = 1..n |> Enum.map( fn _ -> Task.async(worker) end ) |> Enum.map(&Task.await(&1, :infinity))
    Report.generate(results, output)
  end

end
