defmodule Stress do

  def main(args), do: System.halt(main(args, &IO.puts/1, &HTTPoison.get/1))

  def main(args, output, http_client) do
    args |> parse_args |> run(output, http_client)
  end

  defp parse_args(args) do
    OptionParser.parse(args, aliases: [n: :requests],
                              strict: [requests: :integer])
  end

  def usage(output) do
    output.("Stress 0.1")
    output.("Copyright 2017 Thomas Volk")
    output.("usage: stress -n count URL")
  end

  defp run(options, output, http_client) do
    case options do
      {[requests: n], [url], []} ->
        0
      _ ->
        usage(output)
        1
    end
  end

end
