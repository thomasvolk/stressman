defmodule Stress.Worker do
  use Timex
  require Logger

  def start(url, http_client \\ &HTTPoison.get/1) do
     {timestamp, response} = Duration.measure(fn -> http_client.(url) end)
     handle_response({Duration.to_milliseconds(timestamp), response})
  end

  defp handle_response({milliseconds, {:ok, %HTTPoison.Response{ status_code: code}}}) when code >= 200 and code < 300 do
    {:ok, {code, milliseconds}}
  end

  defp handle_response({milliseconds, {:ok, %HTTPoison.Response{ status_code: code}}}) when code >= 300 and code < 400 do
    Logger.info("redirect worker #{node()}-#{inspect self()}: #{code}")
    {:redirect, {code, milliseconds}}
  end

  defp handle_response({milliseconds, {:ok, %HTTPoison.Response{ status_code: code}}}) do
    Logger.error("error worker #{node()}-#{inspect self()}: #{code}")
    {:error, {code, milliseconds}}
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
