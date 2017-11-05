defmodule StressMan.CLI do
  alias StressMan.Cluster
  alias StressMan.Report
  alias StressMan.Scheduler
  alias StressMan.Scheduler.ScheduleTask
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
    StressMan 0.2
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

  defp to_name_list(comma_sep_list) do
     String.split(comma_sep_list, ",") |> Enum.map(&String.trim/1) |> Enum.filter( fn s -> String.length(s) > 0 end ) |> Enum.map(&String.to_atom/1)
  end

  defp run(options, output, client) do
    case options do
      {[duration: duration], [url], []} ->
        task = %ScheduleTask{duration: duration, url: url, client: client}
        Scheduler.schedule(task) |> Report.create() |> Report.print(output)
        0
      {[cookie: cookie, name: name, nodes: nodes, duration: duration], [url], []} ->
        task = %ScheduleTask{duration: duration, url: url, client: client}
        Logger.info("start: #{name}")
        Cluster.init_node(name, cookie)
        to_name_list(nodes) |> Cluster.connect_to_nodes()
        Cluster.schedule(Node.list(), task, &Scheduler.schedule/1) |> Report.create() |> Report.print(output)
        0
      {[cookie: cookie, name: name], [], []} ->
        Logger.info("start server: #{name}")
        Cluster.init_node(name, cookie)
        receive do
           { :halt_server } -> 0
        end
      _ ->
        output.("ERROR: wrong parameter!")
        usage(output)
        1
    end
  end
end
