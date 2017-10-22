defmodule StressMan.CLI do
  alias StressMan.Report
  alias StressMan.Duration
  alias StressMan.Manager
  #alias StressMan.WorkerPool
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
        stressman --requests <REQUESTS> <URL>
      client:
        stressman --manager --cookie <COOKIE> --name <CLIENT_NAME_A@HOST> --nodes <SERVER_NAME_A@HOST>,<SERVER_NAME_B@HOST>,... --requests <REQUESTS> <URL>
      server:
        stressman --server --cookie <COOKIE> --name <SERVER_NAME_A@HOST>
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
      {[requests: n], [url], []} ->
        Duration.measure( fn -> Manager.start(n, url, http_client) end )
          |> Report.generate() |> print_report(output)
        0
      {[client: true, cookie: cookie, name: name, nodes: nodes, requests: n], [url], []} ->
        Logger.info("start client: #{name}")
        init_node(name, cookie)
        to_name_list(nodes) |> connect_to_nodes()
        Duration.measure( fn -> Manager.start(n, url, http_client, Node.list()) end )
          |> Report.generate() |> print_report(output)
        0
      {[server: true, cookie: cookie, name: name], [], []} ->
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
