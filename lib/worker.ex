defmodule StressMan.Worker do
  require Logger
  alias StressMan.Duration, as: Duration

  def start(url, http_client \\ &HTTPoison.get/1) do
     {timestamp, response} = Duration.measure(fn -> http_client.(url) end)
     result = handle_response({timestamp, response})
     Logger.info("worker #{node()}-#{inspect self()} success: #{inspect result}")
     result
  end

  defp handle_response({milliseconds, {:ok, %HTTPoison.Response{ status_code: code}}}) do
    case code do
      code when code >= 200 and code < 300 -> {:ok, {code, milliseconds}}
      code when code >= 300 and code < 400 -> {:redirect, {code, milliseconds}}
      _ -> {:error, {code, milliseconds}}
    end
  end

  defp handle_response({_ms, {:error, reason}}) do
    Logger.error("worker #{node()}-#{inspect self()} error: #{inspect reason}")
    {:error, reason}
  end

  defp handle_response({_ms, _}) do
    Logger.error("worker #{node()}-#{inspect self()} error: unknown")
    {:error, :unknown}
  end
end
