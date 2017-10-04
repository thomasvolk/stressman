defmodule Stress.CLI do
  alias Stress.Report, as: Report
  alias Stress.Duration, as: Duration
  alias Stress.Server, as: Server
  alias Stress.Client, as: Client

  def main(args), do: System.halt(main(args, &IO.puts/1, &HTTPoison.get/1))

  def main(args, output, http_client) do
    args |> parse_args |> run(output, http_client)
  end

  defp parse_args(args) do
    OptionParser.parse(args, aliases: [n: :requests],
                              strict: [requests: :integer, server: :boolean, client: :boolean, name: :string, nodes: :string])
  end

  def usage(output) do
    output.("""
    Stress 0.1
    Copyright 2017 Thomas Volk
    usage:
      start the port mapper daemon first:
        epmd -daemon
      simple:
        stress --requests <REQUESTS> <URL>
      client:
        stress --client --name <CLIENT_NAME_A@HOST> --nodes <SERVER_NAME_A@HOST>,<SERVER_NAME_B@HOST>,... --requests <REQUESTS> <URL>
      server:
        stress --server --name <SERVER_NAME_A@HOST>
    """)
  end

  defp run(options, output, http_client) do
    case options do
      {[requests: n], [url], []} ->
        simple_run(n, url, http_client, output)
        0
      {[client: true, name: name, nodes: nodes, requests: n], [url], []} ->
        node_list = String.split(nodes, ",") |> Enum.map(&String.trim/1) |> Enum.filter( fn s -> String.length(s) > 0 end ) |> Enum.map(&String.to_atom/1)
        {timestamp, results} = Duration.measure( fn -> Client.run(n, String.to_atom(name), node_list, url, http_client) end )
        Report.generate(results, timestamp, output)
        0
      {[server: true, name: name], [], []} ->
        Server.start(String.to_atom(name))
        0
      _ ->
        output.("ERROR: wrong parameter!")
        usage(output)
        1
    end
  end

  def simple_run(n, url, http_client, output) when n > 0 do
    worker = fn -> Stress.Worker.start(url, http_client) end
    {timestamp, results} = Duration.measure( fn -> 1..n |> Enum.map( fn _ -> Task.async(worker) end ) |> Enum.map(&Task.await(&1, :infinity)) end )
    Report.generate(results, timestamp, output)
  end
end
