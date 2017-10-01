defmodule Stress.Worker do
  require Logger
  alias Stress.Duration, as: Duration

  def start(url, http_client \\ &HTTPoison.get/1) do
     {timestamp, response} = Duration.measure(fn -> http_client.(url) end)
     result = handle_response({timestamp, response})
     Logger.debug("worker #{node()}-#{inspect self()} success: #{inspect result}")
     result
  end

  defp handle_response({milliseconds, {:ok, %HTTPoison.Response{ status_code: code}}}) when code >= 200 and code < 300 do
    {:ok, {code, milliseconds}}
  end

  defp handle_response({milliseconds, {:ok, %HTTPoison.Response{ status_code: code}}}) when code >= 300 and code < 400 do
    {:redirect, {code, milliseconds}}
  end

  defp handle_response({milliseconds, {:ok, %HTTPoison.Response{ status_code: code}}}) do
    {:error, {code, milliseconds}}
  end

  defp handle_response({_ms, {:error, reason}}) do
    {:error, reason}
  end

  defp handle_response({_ms, _}) do
    {:error, :unknown}
  end
end
