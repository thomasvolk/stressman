defmodule StressMan.CLI do
  alias StressMan.Duration
  alias StressMan.WorkerPool
  alias StressMan.Analyser
  require Logger

  def main(args), do: System.halt(main(args, &IO.puts/1, &HTTPoison.get/1))

  def main(args, output, http_client) do
    args |> parse_args |> run(output, http_client)
  end

  defp parse_args(args) do
    OptionParser.parse(args, aliases: [n: :requests],
                              strict: [requests: :integer, server: :boolean, manager: :boolean, name: :string, nodes: :string, cookie: :string])
  end

  def usage(output) do
    output.("""
    StressMan 0.1
    Copyright 2017 Thomas Volk
    usage:
      start the port mapper daemon first:
        epmd -daemon
      simple:
        stressman --duration <DURATION> <URL>
      client:
        stressman --cookie <COOKIE> --name <CLIENT_NAME_A@HOST> --nodes <SERVER_NAME_A@HOST>,<SERVER_NAME_B@HOST>,... --duration <DURATION> <URL>
      server:
        stressman --cookie <COOKIE> --name <SERVER_NAME_A@HOST>
    """)
  end

  defp init_node(name, cookie) do
    Node.start(:"#{name}")
    Node.set_cookie(:"#{cookie}")
  end

  defp to_name_list(comma_sep_list) do
     String.split(comma_sep_list, ",") |> Enum.map(&String.trim/1) |> Enum.filter( fn s -> String.length(s) > 0 end ) |> Enum.map(&String.to_atom/1)
  end

  defp connect_to_nodes(node_list), do: node_list |> Enum.each(&Node.connect/1)

  defp run(options, output, http_client) do
    case options do
      {[duration: d], [url], []} ->
        WorkerPool.schedule(d, url)
        Analyser.get() |> print_report(output)
        0
      {[cookie: cookie, name: name, nodes: nodes, duration: d], [url], []} ->
        Logger.info("start: #{name}")
        init_node(name, cookie)
        to_name_list(nodes) |> connect_to_nodes()
        # TODO ...
        0
      {[cookie: cookie, name: name], [], []} ->
        Logger.info("start server: #{name}")
        init_node(name, cookie)
        receive do
           { :halt_server } -> 0
        end
      _ ->
        output.("ERROR: wrong parameter!")
        usage(output)
        1
    end
  end

  def print_report(report, output) do
    output.("""
    total time (ms)       #{report.total_time_ms}

    total:                #{report.total_cnt}
    success:              #{report.success_cnt}
    errors:               #{report.error_cnt}

    success calls
      average (ms):       #{report.average}
      throughput (req/s): #{report.throughput}
    """)
  end
end
