defmodule Stress.Worker do
  use Timex
  require Logger

  def start(url, func \\ &HTTPoison.get/1) do
     {timestamp, response} = Duration.measure(fn -> func.(url) end)
     handle_response({Duration.to_milliseconds(timestamp), response})
  end

  defp handle_response({milliseconds, {:ok, %HTTPoison.Response{ status_code: code}}}) when code >= 200 and code <=304 do
    {:ok, milliseconds}
  end

  defp handle_response({_ms, {:error, reason}}) do
    Logger.error("error worker #{node()}-#{inspect self()}: #{inspect reason}")
    {:error, reason}
  end

  defp handle_response({_ms, _}) do
    Logger.error("error worker #{node()}-#{inspect self()}")
    {:error, :unknown}
  end
end
