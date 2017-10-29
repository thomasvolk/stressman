defmodule StressMan.CLI do
  alias StressMan.WorkerPool
  alias StressMan.Analyser
  require Logger

  def main(args), do: System.halt(main(args, &IO.puts/1, &StressMan.HttpClientHandler.get/1))

  def main(args, output, client) do
    args |> parse_args |> run(output, client)
  end

  defp parse_args(args) do
    OptionParser.parse(args, aliases: [d: :duration],
                              strict: [duration: :integer, name: :string, nodes: :string, cookie: :string])
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

  defp run(options, output, client) do
    case options do
      {[duration: d], [url], []} ->
        WorkerPool.schedule(d, url, client)
        Analyser.get() |> print_report(output)
        0
      {[cookie: cookie, name: name, nodes: nodes, duration: _d], [_url], []} ->
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
    total time (ms)       #{report.total_time}

    total:                #{report.total_count}
    success:              #{report.success_count}
    errors:               #{report.error_count}

    success calls
      average (ms):       #{report.average_duration}
      throughput (req/s): #{report.throughput * 1000}
    """)
  end
end
